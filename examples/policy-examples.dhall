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

let bucketExample1 =
        assert
      :   specificBucketAccess
            "0123456789"
            "us-east-1"
            "my.cool.bucket"
            "my/object/key"
        ≡ { Version = "2012-10-17"
          , Statement =
            [ { Sid = "BucketListing0"
              , Effect = "Allow"
              , Action = [ "s3:ListBucket" ]
              , Resource = [ "arn:aws:s3:::my.cool.bucket" ]
              }
            , { Sid = "ObjectAccess1"
              , Effect = "Allow"
              , Action =
                [ "s3:PutObject"
                , "s3:GetObject"
                , "s3:DeleteObject"
                , "s3:PutObjectAcl"
                ]
              , Resource = [ "arn:aws:s3:::my.cool.bucket/my/object/key/*" ]
              }
            ]
          }

let bucketExample2 =
        assert
      :   specificBucketAccess
            "0123456789"
            "us-east-1"
            "yet.another.bucket"
            "some/other/key"
        ≡ { Version = "2012-10-17"
          , Statement =
            [ { Sid = "BucketListing0"
              , Effect = "Allow"
              , Action = [ "s3:ListBucket" ]
              , Resource = [ "arn:aws:s3:::yet.another.bucket" ]
              }
            , { Sid = "ObjectAccess1"
              , Effect = "Allow"
              , Action =
                [ "s3:PutObject"
                , "s3:GetObject"
                , "s3:DeleteObject"
                , "s3:PutObjectAcl"
                ]
              , Resource =
                [ "arn:aws:s3:::yet.another.bucket/some/other/key/*" ]
              }
            ]
          }

in  { specificBucketAccess = specificBucketAccess }
