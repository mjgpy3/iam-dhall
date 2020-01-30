let L =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/8cf71d94bd63710faae018aac0920b937b977b11/Prelude/List/package.dhall

let Service
    : Type
    = < Lambda
      | Iam
      | Sqs
      | CloudWatch
      | ApiGateway
      | CloudWatchEvents
      | Sns
      | S3
      | CloudFront
      | CodeBuild
      | Ssm
      | Kms
      | QuickSight
      | ResourceGroups
      >

let Action
    : Type
    = { service : Service, permission : Text }

let Arn
    : Type
    = { service : Service, resource : Text }

let Effect
    : Type
    = < Allow | Deny >

let Resource
    : Type
    = < ByArn : Arn | All >

let Statement
    : Type
    = { sid : Text
      , effect : Effect
      , actions : List Action
      , resources : List Resource
      }

let Policy
    : Type
    = List Statement

let policy
    : List Statement → Policy
    = λ(statements : List Statement) → statements

let serviceAllowResources
    : Service → List Text → List Resource → Statement
    =   λ(service : Service)
      → λ(permissions : List Text)
      → λ(resources : List Resource)
      → { sid = ""
        , effect = Effect.Allow
        , actions =
            L.map
              Text
              Action
              (   λ(permission : Text)
                → { permission = permission, service = service }
              )
              permissions
        , resources = resources
        }

let serviceAllow
    : Service → List Text → List Text → Statement
    =   λ(service : Service)
      → λ(permissions : List Text)
      → λ(resources : List Text)
      → serviceAllowResources
          service
          permissions
          ( L.map
              Text
              Resource
              (   λ(resource : Text)
                → Resource.ByArn { service = service, resource = resource }
              )
              resources
          )

let serviceAllowAll
    : Service → List Text → Statement
    =   λ(service : Service)
      → λ(permissions : List Text)
      → serviceAllowResources service permissions [ Resource.All ]

in  { Service = Service
    , Action = Action
    , Arn = Arn
    , Effect = Effect
    , Resource = Resource
    , Statement = Statement
    , Policy = Policy
    , policy = policy
    , serviceAllow = serviceAllow
    , serviceAllowAll = serviceAllowAll
    }
