import argparse
import re
from pathlib import Path

PRINT_LINE = '    v8::base::OS::Print("IC transition\\n");\n'
PRINT_LINE_2SP = '  v8::base::OS::Print("IC transition\\n");\n'

def read_text(p: Path) -> str:
    return p.read_text(encoding="utf-8", errors="strict")

def write_text(p: Path, s: str) -> None:
    p.write_text(s, encoding="utf-8", errors="strict")

def backup_file(p: Path) -> Path:
    bak = p.with_suffix(p.suffix + ".bak")
    if not bak.exists():
        bak.write_bytes(p.read_bytes())
    return bak

def patch_ic_h(v8_root: Path) -> bool:
    p = v8_root / "src" / "ic" / "ic.h"
    s = read_text(p)
    if 'v8::base::OS::Print("IC transition\\n");' in s:
        return False

    pat = r'(void\s+MarkRecomputeHandler\s*\(\s*DirectHandle<Object>\s+name\s*\)\s*\{\s*\n)([ \t]*DCHECK\s*\(\s*RecomputeHandlerForName\s*\(\s*name\s*\)\s*\)\s*;\s*\n)'
    m = re.search(pat, s, flags=re.MULTILINE)
    if not m:
        raise RuntimeError(f"pattern not found in {p} for MarkRecomputeHandler/DCHECK")

    insert_indent = re.match(r'^([ \t]*)', m.group(2)).group(1)
    ins = insert_indent + 'v8::base::OS::Print("IC transition\\n");\n'
    s2 = s[:m.end(2)] + ins + s[m.end(2):]
    backup_file(p)
    write_text(p, s2)
    return True

def patch_ic_cc(v8_root: Path) -> bool:
    p = v8_root / "src" / "ic" / "ic.cc"
    s = read_text(p)
    if 'v8::base::OS::Print("IC transition\\n");' in s:
        pass

    sig = r'void\s+IC::OnFeedbackChanged\s*\(\s*Isolate\*\s+isolate\s*,\s*Tagged<FeedbackVector>\s+vector\s*,\s*\n\s*FeedbackSlot\s+slot\s*,\s*const\s+char\*\s+reason\s*\)\s*\{'
    m = re.search(sig, s, flags=re.MULTILINE)
    if not m:
        raise RuntimeError(f"function signature not found in {p} for IC::OnFeedbackChanged")

    body_start = m.end()
    after = s[body_start:]
    idx_notify = after.find("  isolate->tiering_manager()->NotifyICChanged(vector);")
    if idx_notify < 0:
        raise RuntimeError(f"NotifyICChanged line not found in {p} inside IC::OnFeedbackChanged")

    before_notify = after[:idx_notify]
    if 'v8::base::OS::Print("IC transition\\n");' in before_notify:
        return False

    insert = PRINT_LINE_2SP
    after2 = before_notify + insert + after[idx_notify:]
    s2 = s[:body_start] + after2
    backup_file(p)
    write_text(p, s2)
    return True

def patch_flags(v8_root: Path) -> bool:
    p = v8_root / "src" / "flags" / "flag-definitions.h"
    s = read_text(p)

    pat = r'(DEFINE_BOOL\s*\(\s*trace_elements_transitions\s*,\s*)(false)(\s*,\s*"trace elements transitions"\s*\)\s*)'
    m = re.search(pat, s)
    if not m:
        if re.search(r'DEFINE_BOOL\s*\(\s*trace_elements_transitions\s*,\s*true\s*,\s*"trace elements transitions"', s):
            return False
        raise RuntimeError(f"DEFINE_BOOL(trace_elements_transitions, ...) not found in {p}")

    s2 = s[:m.start(2)] + "true" + s[m.end(2):]
    if s2 == s:
        return False
    backup_file(p)
    write_text(p, s2)
    return True

def patch_js_objects_cc(v8_root: Path) -> bool:
    p = v8_root / "src" / "objects" / "js-objects.cc"
    s = read_text(p)

    fn_pat = r'void\s+JSObject::PrintInstanceMigration\s*\(\s*FILE\*\s+file\s*,\s*Tagged<Map>\s+original_map\s*,\s*\n\s*Tagged<Map>\s+new_map\s*\)\s*\{'
    m = re.search(fn_pat, s, flags=re.MULTILINE)
    if not m:
        raise RuntimeError(f"PrintInstanceMigration signature not found in {p}")

    fn_start = m.start()
    search_region = s[fn_start:fn_start + 20000]

    if 'PrintF(file, "[migrating]");/*' in search_region or 'PrintF(file, "[migrating]"); /*' in search_region:
        return False

    anchor = 'PrintF(file, "[migrating]");'
    a = search_region.find(anchor)
    if a < 0:
        raise RuntimeError(f'anchor {anchor!r} not found near PrintInstanceMigration in {p}')

    region_after_anchor = search_region[a + len(anchor):]
    start_line = "Isolate* isolate = Isolate::Current();"
    b = region_after_anchor.find(start_line)
    if b < 0:
        raise RuntimeError(f"{start_line!r} not found after migrating print in {p}")

    end_line = 'new_map->elements_kind());'
    c = region_after_anchor.find(end_line, b)
    if c < 0:
        raise RuntimeError(f"{end_line!r} not found after isolate line in {p}")

    nl_after_end = region_after_anchor.find("\n", c)
    if nl_after_end < 0:
        raise RuntimeError(f"newline not found after end_line in {p}")

    close_brace_line = region_after_anchor.find("\n", nl_after_end + 1)
    if close_brace_line < 0:
        close_brace_line = nl_after_end

    start_idx = fn_start + a + len(anchor) + b
    end_idx = fn_start + a + len(anchor) + nl_after_end + 1

    block = s[start_idx:end_idx]
    if "/*" in block or "*/" in block:
        raise RuntimeError(f"block already seems commented or contains comment markers in {p}")

    s2 = s[:fn_start + a + len(anchor)] + "/*" + s[fn_start + a + len(anchor):start_idx] + block + "*/" + s[end_idx:]
    backup_file(p)
    write_text(p, s2)
    return True

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("v8_dir", help="Path to V8 repository root")
    args = ap.parse_args()

    v8_root = Path(args.v8_dir).resolve()
    if not v8_root.exists():
        raise SystemExit(f"v8_dir not found: {v8_root}")

    changed = []
    if patch_ic_h(v8_root): changed.append("src/ic/ic.h")
    if patch_ic_cc(v8_root): changed.append("src/ic/ic.cc")
    if patch_flags(v8_root): changed.append("src/flags/flag-definitions.h")
    if patch_js_objects_cc(v8_root): changed.append("src/objects/js-objects.cc")

    if changed:
        print("Patched:")
        for x in changed:
            print(f"  - {x}")
        print("Backups created as *.bak (only if not already present).")
    else:
        print("No changes needed (already patched).")

if __name__ == "__main__":
    main()
