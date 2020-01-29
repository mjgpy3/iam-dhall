let P =
      https://raw.githubusercontent.com/mjgpy3/iam-dhall/20bcc9c507d353fb3736a633280239a922b91aa6/policy.dhall

let policy =
      https://raw.githubusercontent.com/mjgpy3/iam-dhall/20bcc9c507d353fb3736a633280239a922b91aa6/output.dhall

let specificBucketAccess =
        λ(accountId : Text)
      → λ(region : Text)
      → λ(bucket : Text)
      → λ(key : Text)
      → policy
          { accountId = accountId, region = region }
          [   P.serviceAllow P.Service.S3 [ "ListBucket" ] [ bucket ]
            ⫽ { sid = "BucketListing" }
          ,   P.serviceAllow
                P.Service.S3
                [ "PutObject", "GetObject", "DeleteObject", "PutObjectAcl" ]
                [ "${bucket}/${key}/*" ]
            ⫽ { sid = "ObjectAccess" }
          ]

in  { specificBucketAccess = specificBucketAccess }
