<div align="center">
  <hr />
    <h2 align="center" style="border-bottom: none"><img style="position: relative; top: 0.25rem;" src="https://raw.githubusercontent.com/aiken-lang/branding/main/assets/icon.png" alt="Aiken" height="30" /> aiken/bench</h2>

[![Licence](https://img.shields.io/github/license/aiken-lang/bench?style=for-the-badge)](https://github.com/aiken-lang/bench/blob/main/LICENSE)
[![Continuous Integration](https://img.shields.io/github/actions/workflow/status/aiken-lang/bench/continuous-integration.yml?style=for-the-badge)](https://github.com/aiken-lang/bench/actions/workflows/continuous-integration.yml)
  <hr/>
</div>

The official library for writing _samplers_ (a.k.a Scaled Fuzzers) for the [Aiken](https://aiken-lang.org) Cardano smart-contract language.

> ### ⚠️ WARNING
> 
> **IMPORTANT:** This is a work in progress and the API is not stable yet; additionally Samplers are not yet supported in the current version of Aiken (v1.1.9).

## Installation

```
aiken add aiken-lang/bench --version v0.0.0
```

## Getting started

First, make sure you have the [Aiken's user manual about tests](https://aiken-lang.org/language-tour/tests#property-based-test); in particular the section about benchmarking functions.

In many situations, you can use primitives from this library out-of-the-box, composing them inline when necessary. For example, if you need a growing non-empty list of values, you can simply write:

```
use aiken/bench

bench my_bench(xs via bench.list(bench.int(Linear(1)), Linear(1))) {
  // some function
}
```

You can also write your own more complex sampler. Note that writing good samplers can be complicated, so here are a few guiding principles you should follow.. TODO