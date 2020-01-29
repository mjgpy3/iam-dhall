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
          }
          service

let effect
    : P.Effect → Text
    = λ(effect : P.Effect) → merge { Allow = "Allow", Deny = "Deny" } effect

let action
    : P.Action → Text
    =   λ(action : P.Action)
      → "${serviceIdentifier action.service}:${action.permission}"

let arn
    : Aws → P.Arn → Text
    =   λ(aws : Aws)
      → λ(arn : P.Arn)
      → "arn:aws:${serviceIdentifier
                     arn.service}:${aws.region}:${aws.accountId}:${arn.resource}"

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
