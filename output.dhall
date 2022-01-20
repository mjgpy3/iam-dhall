let L =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/8cf71d94bd63710faae018aac0920b937b977b11/Prelude/List/package.dhall

let P = ./policy.dhall

let IamStatement
    : Type
    = { Sid : Text, Effect : Text, Action : List Text, Resource : List Text }

let IamPolicy
    : Type
    = { Version : Text, Statement : List IamStatement }

let Aws
    : Type
    = { accountId : Text, region : Text }

let serviceIdentifier
    : P.Service → Text
    =   λ(service : P.Service)
      → merge
          { Lambda = "lambda"
          , Iam = "iam"
          , Sqs = "sqs"
          , CloudWatch = "cloudwatch"
          , ApiGateway = "apigateway"
          , CloudWatchEvents = "events"
          , Sns = "sns"
          , S3 = "s3"
          , CloudFront = "cloudfront"
          , CodeBuild = "codebuild"
          , Ssm = "ssm"
          , Kms = "kms"
          , QuickSight = "quicksight"
          , ResourceGroups = "resource-groups"
          , ExecuteApi = "execute-api"
          , Prometheus = "aps"
          }
          service

let effect
    : P.Effect → Text
    = λ(effect : P.Effect) → merge { Allow = "Allow", Deny = "Deny" } effect

let action
    : P.Action → Text
    =   λ(action : P.Action)
      → "${serviceIdentifier action.service}:${action.permission}"

let arnAccountId
    : Aws → P.Arn → Text
    =   λ(aws : Aws)
      → λ(arn : P.Arn)
      → merge
          { ApiGateway = ""
          , S3 = ""
          , Lambda = aws.accountId
          , Iam = aws.accountId
          , Sqs = aws.accountId
          , CloudWatch = aws.accountId
          , CloudWatchEvents = aws.accountId
          , Sns = aws.accountId
          , CloudFront = aws.accountId
          , CodeBuild = aws.accountId
          , Ssm = aws.accountId
          , Kms = aws.accountId
          , QuickSight = aws.accountId
          , ResourceGroups = aws.accountId
          , ExecuteApi = aws.accountId
          , Prometheus = aws.accountId
          }
          arn.service

let arnRegion
    : Aws → P.Arn → Text
    =   λ(aws : Aws)
      → λ(arn : P.Arn)
      → merge
          { ApiGateway = aws.region
          , S3 = ""
          , Lambda = aws.region
          , Iam = aws.region
          , Sqs = aws.region
          , CloudWatch = aws.region
          , CloudWatchEvents = aws.region
          , Sns = aws.region
          , CloudFront = aws.region
          , CodeBuild = aws.region
          , Ssm = aws.region
          , Kms = aws.region
          , QuickSight = aws.region
          , ResourceGroups = aws.region
          , ExecuteApi = aws.region
          , Prometheus = aws.region
          }
          arn.service

let arn
    : Aws → P.Arn → Text
    =   λ(aws : Aws)
      → λ(arn : P.Arn)
      → "arn:aws:${serviceIdentifier
                     arn.service}:${arnRegion aws arn}:${arnAccountId
                                                           aws
                                                           arn}:${arn.resource}"

let resource
    : Aws → P.Resource → Text
    =   λ(aws : Aws)
      → λ(resource : P.Resource)
      → merge { ByArn = arn aws, All = "*" } resource

let statement
    : Aws → { index : Natural, value : P.Statement } → IamStatement
    =   λ(aws : Aws)
      → λ(statement : { index : Natural, value : P.Statement })
      → { Sid = "${statement.value.sid}${Natural/show statement.index}"
        , Effect = effect statement.value.effect
        , Action = L.map P.Action Text action statement.value.actions
        , Resource =
            L.map P.Resource Text (resource aws) statement.value.resources
        }

let version = "2012-10-17"

let policy
    : Aws → P.Policy → IamPolicy
    =   λ(aws : Aws)
      → λ(policy : P.Policy)
      → { Version = version
        , Statement =
            L.map
              { index : Natural, value : P.Statement }
              IamStatement
              (statement aws)
              (L.indexed P.Statement policy)
        }

in  policy
