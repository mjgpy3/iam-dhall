# Examples

## Simple Policy

For example, given the example in [`policy-examples.dhall`](./policy-examples.dhall), running `dhall-to-json` like so

``` shell
dhall-to-json <<< '(./policy-examples.dhall).specificBucketAccess "0123456789" "us-east-1" "cool.bucket" "some/path"'
```

generates policy JSON

``` json
{
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::cool.bucket"
      ],
      "Sid": "BucketListing0"
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::cool.bucket/some/path/*"
      ],
      "Sid": "ObjectAccess1"
    }
  ],
  "Version": "2012-10-17"
}
```

Of course, any `Text` values can be passed to `specificBucketAccess`, or environment variables can be supplied via dhall's `env:VAR_NAME` syntax.
