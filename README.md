# iam-dhall
Create IAM policies using [dhall][dhall].

## Usage

These dhall files were tested using `dhall-to-json` version `1.6.1` though I
expect them to be compatible with other versions of the tool.

See the [examples](./examples) for usage examples.

## Why?

With all the nitty-gritty little services in AWS and their interdependence,
creating IAM policies correctly (and maintaining them) can become quite
daunting. This gets increasingly difficult in highly sensitive areas, e.g.
healthcare, national defense, etc... where components are generally expected to
abide by the [principle of least privilege][polp].

But these are not the only challenges provided by IAM policies

 - many policy errors don't surface until the policy is actually created (or,
 heaven forbid, during run-time) and JSON doesn't help to illuminate some of the
 easier-to-detect configuration errors
 - JSON is inherently schema-less though IAM policies actually have a schema,
 albeit a simple one
 - JSON doesn't compose or express dependencies without bolting on another
 programming language or nesting a wacky, unnatural DSL (again requiring another
 language for interpretation)
 
I believe that [dhall][dhall] speaks to each of these issues.

  [dhall]: https://dhall-lang.org/
  [polp]: https://en.wikipedia.org/wiki/Principle_of_least_privilege
