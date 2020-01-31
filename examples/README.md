# Examples

## Simple Policy

[`policy-examples.dhall`](./policy-examples.dhall) contains tests showing how policies might be generated.

In these test cases, the dhall code on the right of the assertions is almost one-to-one with the JSON you would want for a policy. But, to actually generated the policy JSON you could run something like the following.

``` shell
dhall-to-json <<< '(./policy-examples.dhall).specificBucketAccess "0123456789" "us-east-1" "cool.bucket" "some/path"'
```

The example functions use arguments to specify inputs, but it's easy enough to use dhall's `env:ENV_VAR` syntax to populate them with environment variables, if that's preferred.
