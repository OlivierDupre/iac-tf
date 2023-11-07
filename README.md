# IaC Terraform

Provision Infrastructure using Terraform and GitLab CI.

## Environments

### Workflow

The diagram below shows a high level view of the workflow being implemented in this project.

Legend:

* Rounded boxes are the GitLab branches.
* Square boxes are the environments.
* Text on the arrows are the actions to flow from one box to the next one.
* Angled square is a decision step.

```mermaid
flowchart LR
    A(main) -->|new feature| B(feature_X)

    B -->|auto deploy| C[review/feature_X]
    B -->|merge| D(main)
    C -->|destroy| D

    D -->|auto deploy| E[integration]
    E -->|manual| F[recette]

    D -->|tag| G(X.Y.Z)
    F -->|validate| G

    G -->|auto deploy| H[prex]
    H -->|manual| I{plan}
    I -->|manual| J[production]
``````

### Review

This will provision a temporary environment in review for all feature branches. That env is automatically deleted when the MR is closed.

### Integration

This will provision a more reliable environment from the main branch.
This still can be manually deleted from the pipeline job `destroy` if the CI variable `TF_DESTROY` is set to true.

### Recette

This is a second layer of environments for the main branch.
This can for example be used for tests that cannot be reliably run on the **Integration** environment.
This one is designed to be more reliable than **Integration** and as such its deployments are triggered manually, in a [downstream pipeline](https://docs.gitlab.com/ee/ci/pipelines/downstream_pipelines.html) from the default branch.

**This environment and next ones cannot be destroyed from the pipeline to prevent mistakes.**

### Prex

This is the Pre-Exploitation environment. Designed to be both the last validation step and a fallback for the Production.
This is automatically deployed when a new tag is pushed.

### Production

This will provision a long lasting production environment from each tag, in a [downstream pipeline](https://docs.gitlab.com/ee/ci/pipelines/downstream_pipelines.html), after deployment to **Prex**.

## Variables

A set of variables are necessary to deploy the infrastructure. Some are needed by the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables), others are passed as [terraform/variables.tf](./terraform/variables.tf), or needed by the pipeline to adapt its behavior:

### Needed by the provider

These variables must be provided as [GitLab CI variables](https://docs.gitlab.com/ee/ci/variables/). They can all be [environment specific](https://docs.gitlab.com/ee/ci/environments/index.html#limit-the-environment-scope-of-a-cicd-variable).

* `AWS_ACCESS_KEY_ID` the access key to log in the account where the infrastructute will be deployed.
* `AWS_SECRET_ACCESS_KEY` the secret key associated to the `AWS_ACCESS_KEY_ID`. This should be [environment specific](https://docs.gitlab.com/ee/ci/environments/index.html#limit-the-environment-scope-of-a-cicd-variable) as well or pulled from [Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) or [Vault](https://www.vaultproject.io/).
* `AWS_KEY_PAIR` the name of the [AWS KeyPair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) to use to SSH to the EC2 instances.

### GitLab variables

These variables are defined in [./terraform/variables.tf](./terraform/variables.tf).

They can be valued either from a [GitLab CI variables](https://docs.gitlab.com/ee/ci/variables/) or from the environment specific `.tfvars` files in [vars](./vars/).

In the GitLab CI variables, they can also be secured and defined specifically for each environment with the [environment-specific variables](https://about.gitlab.com/blog/2021/04/09/demystifying-ci-cd-variables/#custom-cicd-variables).

* `AWS_AMI_ID` the AMI of the [AWS Image](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami.html) to use when deploying the EC2.
* `AWS_DEFAULT_REGION` any AWS region where your infrasturcture is supported. **Optional**. Defaults to `eu-west-3`.
* `AWS_INSTANCE_TYPE` any EC2 instance type available in the region where you are deploying your EC2. **Optional**. Defaults to `t2.micro`.

### GitLab CI specific

This variable is used to control the CI/CD behavior.

* `TF_DESTROY` set to `true` to enable manual destroy of `staging` (from the main branch) environment.
