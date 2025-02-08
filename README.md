<div align="center        run: cargo install --verbose --git https://github.com/aiken-lang/aiken.git">
  <hr />
    <h2 align="center" style="border-bottom: none"><img style="position: relative; top: 0.25rem;" src="https://raw.githubusercontent.com/aiken-lang/branding/main/assets/icon.png" alt="Aiken" height="30" /> aiken/sample</h2>

[![Licence](https://img.shields.io/github/license/aiken-lang/sample?style=for-the-badge)](https://github.com/aiken-lang/sample/blob/main/LICENSE)
[![Continuous Integration](https://img.shields.io/github/actions/workflow/status/aiken-lang/sample/continuous-integration.yml?style=for-the-badge)](https://github.com/aiken-lang/sample/actions/workflows/continuous-integration.yml)
  <hr/>
</div>

The official library for writing _samplers_ (a.k.a Scaled Fuzzers) for the [Aiken](https://aiken-lang.org) Cardano smart-contract language.

> [!WARNING]
>
> This is a work in progress and the API is not stable yet; The sample API for benchmarks is only supported since aiken==1.1.11;

## Installation

```
aiken add aiken-lang/sample --version v0.0.0
```

## Getting started

```aiken
use aiken/sample.{Linear}

fn my_function(n: Int) -> Int {
  n * 2
}

bench multiply_bench(n via sample.int(Linear(5))) {
  my_function(n)
}
```

> [!TIP]
>
> For more information, read the [user manual](https://aiken-lang.org/language-tour/bench).
