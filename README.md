# Scratch Fuzzilli

A state aware fuzzer that improves on the existing Fuzzilli (https://github.com/googleprojectzero/fuzzilli)

## Usage

The basic steps to use this fuzzer are:

1. clone repository
```
git clone https://github.com/scratch-bug/scratch_fuzzilli.git
```

2. patch v8 with running `Tools/patch_v8.py`
need to modify V8 so that Fuzzilli can better track transitions. simply run patch_v8.py targeting the V8 directory once. 
```
python3 Tools/patch_v8.py /path/to/v8
```

3. build v8 with fuzzbuild args

4. Compile the fuzzer
```
swift build [-c release]
```

5. Run the fuzzer
```
swift run [-c release] FuzzilliCli --profile=<profile> [other cli options] /path/to/d8
```

### Mutator

In addition to the existing mutators, we have implemented ElementsKindMutator and ICTransitionMutator to specifically focus on state transitions. These are not included in the main branch, so you must switch to the mutator branch to use them.
```
git fetch origin
git checkout -b mutator origin/mutator
```

## Concept

While standard Fuzzilli is a coverage-guided fuzzer, our Scratch Fuzzilli is a state-aware fuzzer.
An analysis of crashes found by Fuzzilli reveals a high frequency of Type Confusion vulnerabilities. These often occur during state transitions within V8, such as transitions from Packed to Holey or Smi to Double.
The concept of state-aware fuzzing is well-documented in other domains. For instance, research on state-aware fuzzing targeting Linux drivers is available here. Motivated by this, we have enhanced Fuzzilli to focus on state transitions.

Key Improvements:
1. Weighted Corpus based on Transitions: We assigned weights to the corpus based on state transition types. By enabling specific d8 options (e.g., --trace-elements), V8 outputs logs corresponding to these transitions. Fuzzilli is configured to track and parse these logs directly to apply appropriate weights.
2. AI-Generated Corpus (CodeQL): Although not detailed in this repository, we analyzed numerous 1-day state transition vulnerabilities and patterned them using CodeQL. We then utilized AI to generate a corpus specifically designed to traverse these vulnerable V8 code paths. (You can check ql queries at `codeql/`)
3. State-Transition Mutators: We developed custom Mutators dedicated to state transitions. Currently, ElementsKindTransitionMutator and ICTransitionMutator are implemented, with plans to add more in the future.
Note: Weights for specific state transitions and Mutators can be reconfigured by directly modifying the source code.

Through these improvements, the fuzzer is designed to induce a higher frequency of vulnerable state transitions within the JavaScript engine.


## Result
As of 2025-12-20, a total of 28 crashes were found, and 5 bugs were fixed, excluding duplication.

## Disclaimer

This is not an officially supported Google product.

Customized by BOB 14th Scratch BugBug! Team.
