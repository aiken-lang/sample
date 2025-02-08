use aiken/builtin
use aiken/collection/dict
use aiken/crypto

/// A growth pattern determines how complexity scales with input size
pub type Growth {
  /// Constant growth: f(n) = c
  Constant
  /// Linear growth: f(n) = n
  Linear(Int)
  /// Exponential growth: f(n) = 2^n
  Exponential(Int)
  /// Logarithmic growth: f(n) = log(n)
  Logarithmic(Int)
}

/// Core random number generator that produces a byte (0-255)
fn rand(prng: PRNG) -> Option<(PRNG, Int)> {
  when prng is {
    Seeded { seed, choices } -> {
      let choice = builtin.index_bytearray(seed, 0)
      Some(
        (
          Seeded {
            seed: crypto.blake2b_256(seed),
            choices: builtin.cons_bytearray(choice, choices),
          },
          choice,
        ),
      )
    }
    Replayed { cursor, choices } ->
      if cursor >= 1 {
        let cursor = cursor - 1
        Some(
          (
            Replayed { cursor, choices },
            builtin.index_bytearray(choices, cursor),
          ),
        )
      } else {
        None
      }
  }
}

/// Apply a growth pattern to scale an input size
pub fn apply_growth(pattern: Growth, n: Int) -> Int {
  when pattern is {
    Constant -> 1
    Linear(base) -> base * n
    Exponential(base) ->
      if n <= 0 {
        0
      } else {
        exp_int_helper(base, n, 1)
      }
    Logarithmic(base) ->
      if n <= 1 {
        0
      } else {
        count_divisions(base, n, 0)
      }
  }
}

// TODO: Probably need to use a builtin in the future.
fn exp_int_helper(base: Int, n: Int, acc: Int) -> Int {
  if base <= 0 {
    acc
  } else {
    exp_int_helper(base - 1, n, acc * n)
  }
}

// TODO: Probably need to use a builtin in the future.
fn count_divisions(base: Int, n: Int, acc: Int) -> Int {
  if n <= 1 {
    acc
  } else {
    count_divisions(base, n / base, acc + 1)
  }
}

// SAMPLERS:

/// Create a constant sampler that always returns the same value
pub fn constant(x: a) -> Sampler<a> {
  fn(_n) { fn(prng) { Some((prng, x)) } }
}

/// Create a sampler that generates integers with configurable growth
pub fn int(growth: Growth) -> Sampler<Int> {
  fn(n) -> Fuzzer<Int> {
    let scaled_multiplier = apply_growth(growth, n)
    fn(prng) {
      when rand(prng) is {
        Some((new_prng, value)) -> Some((new_prng, value * scaled_multiplier))
        None -> None
      }
    }
  }
}

/// Generate bytestrings with length scaling according to the growth pattern
pub fn bytestring(growth: Growth) -> Sampler<ByteArray> {
  fn(n) {
    let length_fuzzer = int(growth)(n)
    fn(prng) {
      when length_fuzzer(prng) is {
        Some((_prng2, _len)) -> todo
        None -> None
      }
    }
  }
}

fn list_handler(
  items_so_far: List<a>,
  i: Int,
  scaled_length: Int,
  fuzzer: Fuzzer<a>,
  prng: PRNG,
) -> Option<(PRNG, List<a>)> {
  if i > scaled_length {
    Some((prng, items_so_far))
  } else {
    when fuzzer(prng) is {
      Some((new_prng, item)) ->
        list_handler(
          [item, ..items_so_far],
          i + 1,
          scaled_length,
          fuzzer,
          new_prng,
        )
      None -> None
    }
  }
}

/// Create a sampler that generates lists with configurable growth
pub fn list(element_sampler: Sampler<a>, growth: Growth) -> Sampler<List<a>> {
  fn(n) {
    let scaled_length = apply_growth(growth, n)
    let element_fuzzer = element_sampler(n)
    fn(prng) { list_handler([], 0, scaled_length, element_fuzzer, prng) }
  }
}

pub fn pair(
  first_sampler: Sampler<a>,
  second_sampler: Sampler<b>,
) -> Sampler<Pair<a, b>> {
  fn(n) {
    let first_fuzzer = first_sampler(n)
    let second_fuzzer = second_sampler(n)
    fn(prng) {
      when first_fuzzer(prng) is {
        Some((prng2, first_val)) ->
          when second_fuzzer(prng2) is {
            Some((prng3, second_val)) ->
              Some((prng3, Pair(first_val, second_val)))
            None -> None
          }
        None -> None
      }
    }
  }
}

pub fn pairs(
  first_sampler: Sampler<a>,
  second_sampler: Sampler<b>,
  growth: Growth,
) {
  fn(n) {
    let scaled_length = apply_growth(growth, n)
    let pair_sampler = pair(first_sampler, second_sampler)(n)

    fn(prng) { list_handler([], 0, scaled_length, pair_sampler, prng) }
  }
}

pub fn dict(
  key_sampler: Sampler<ByteArray>,
  value_sampler: Sampler<a>,
  growth: Growth,
) {
  fn(n) {
    let _scaled_length = apply_growth(growth, n)
    map(
      pairs(key_sampler, value_sampler, growth),
      fn(pairs) { dict.from_pairs(pairs) },
    )
  }
}

pub fn map(sampler: Sampler<a>, f: fn(a) -> b) -> Sampler<b> {
  fn(n) {
    let fuzzer = sampler(n)
    fn(prng) {
      when fuzzer(prng) is {
        Some((prng2, a)) -> Some((prng2, f(a)))
        None -> None
      }
    }
  }
}

pub fn map2(
  sampler: Sampler<a>,
  sampler2: Sampler<b>,
  f: fn(a, b) -> c,
) -> Sampler<c> {
  fn(n) {
    let fuzzer1 = sampler(n)
    let fuzzer2 = sampler2(n)
    fn(prng) {
      when fuzzer1(prng) is {
        Some((prng2, a)) ->
          when fuzzer2(prng2) is {
            Some((prng3, b)) -> Some((prng3, f(a, b)))
            None -> None
          }
        None -> None
      }
    }
  }
}
