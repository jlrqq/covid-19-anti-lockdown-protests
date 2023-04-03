<h2 align='center'> 🔒🦠 COVID-19 Anti-Lockdown 🦠🔒 </h2>

## Business Problem 
- As COVID-19 spreads across the globe, many countries have instituted measures on freedom of movement to control the spread of the disease. For instance, citizens are not allowed to leave their homes except for work or buying essential supplies. With an individualistic culture in the US, several major protests were observed by libertarian supporters protecting individual freedoms. 
- Therefore, we would like to explore the topic of Anti-Lockdown to understand how the general public are reacting to lockdown policies. Our guiding questions include:
    - What are the sentiments and key topics social media users typically communicate after a lockdown policy is enforced? How have the sentiments and discussion topics changed overtime?
    - How are the negative sentiments towards COVID-19 lockdown circulated on social media platforms such as Twitter and Reddit?
    - Case study: One of the more brutal approaches to COVID-19 lockdown is from China’s government. What are the discussion topics and sentiments towards this policy on their social media platform, Weibo? How does it differ from Twitter (a more unfiltered platform)? 
- Our main intended audience are the policymakers. The insights derived from our guiding questions will help policymakers to understand factors that drive resistance and craft more effective communication strategies. 

## Objective 
The objective of our analysis will cover Social Network Analysis to understand the network of users spreading negative sentiments, Text Sentiment Analysis to understand the different emotions faced by affected users and lastly, Topic Modelling to understand the key occurring topics appearing in discussions on social media platforms.

## Data Set Collection
- Scraped from Twitter API, Snscrape
- Scraped from Reddit API
- Scraped from Weibo

# Getting Start
## Prerequisites

### [python](<https://python.org>)

Install Python 3 (Ubuntu 20.04)
```bash
sudo apt install python-is-python3
sudo apt install python3
```

### [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
To compile the Terraform binary from source, clone the HashiCorp Terraform repository.

```
git clone https://github.com/hashicorp/terraform.git
```
Navigate to the new directory. Then, compile the binary. This command will compile the binary and store it in $GOPATH/bin/terraform.
```
cd terraform
go install
```
Finally, make sure that the terraform binary is available on your PATH. This process will differ depending on your operating system.

### [AWS SDK](https://aws.amazon.com/sdk-for-javascript/)
Installing the SDK for JavaScript
```
npm install aws-sdk
```
Set tempoaray credentials in the AWS credentials profile file on your local system, located at:

- ~/.aws/credentials on Linux, macOS, or Unix
- C:\Users\USERNAME\.aws\credentials on Windows

In the credentials file, copy the following placeholder text and paste it in working temporary credentials.

```
[default]
aws_access_key_id=<value from AWS access portal>
aws_secret_access_key=<value from AWS access portal>
aws_session_token=<value from AWS access portal>
```

Refer to https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/signup-create-iam-user.html#setup-temp-creds for more details on the basic setup to work with AWS Services.


## Building AWS Infrastructure
### Clone the repo
```
https://github.com/jlrqq/covid-19-anti-lockdown-protests.git
```

Navigate to ./Infrastructure/terraform directory
```
cd Infrastructure/terraform
```

### Dependencies Pre-installed
Unfortunately, AWS Lambda has a bad integration with Pandas and Numpy libraries as the version required is different from the same version of python 3.9. 

This project will help you with the installation of the dependencies required for the project. And it will also help you to create the AWS Lambda that is able to execute the code. 

For the details, you may refer to [./Infrastructure/terraform/README.md](./Infrastructure/terraform/README.md)

### Install dependencies
Download numpy from [here](https://pypi.org/project/numpy/#files)

`
Please note that the version must be 1.24.2 with cp38 with manylinux
`

`
for example: pandas-1.24.2-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
`

Download numpy from [here](https://pypi.org/project/numpy/#files)

`
Please note that the version must be 1.5.3 with cp38 with manylinux
`

`
For Example: pandas-1.5.3-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
`

Once the package is downloaded, you may move the documents to the ./Infrastructure/code directory

### Initialize Terraform

1. Create var.tfvars file based on the example of var.tfvars.example
```
cp var.tfvars.example var.tfvars
```

2. Initalied terraform
```
terraform init
```
3. Create the infrastructure
```
terraform apply -var-file=var.tfvars
```
In this step, there will be a prompt to confirm the creation of the infrastructure. Type "yes" to continue. 

4. If you wish to stop all services, you can destroy the infrastructure
```
terraform destroy -var-file=var.tfvars
```

## Running the code
### Use Deepnote
- [Deepnote](https://deepnote.com/) is a cloud-based Jupyter notebook that allows you to run code in the cloud.
- You may refer to [Deepnote docs](https://deepnote.com/docs) for more details on how to use Deepnote.

### Use Anaconda & Jupyter notebook (Recommended)
- [Anaconda](https://www.anaconda.com/) is a free and open-source distribution of the Python and R programming languages for scientific computing, that aims to simplify package management and deployment.
- If you have Anaconda installed, you may refer to [Jupyter docs](https://jupyter.readthedocs.io/en/latest/) for more details on how to use Jupyter notebook.
- To start a jupyter notebook server, simply run the following command in the terminal:
```
cd ./Reddit_Sentiment_Analysis && jupyter notebook
```
This will start a jupyter notebook server at http://localhost:8888

### Use Google Colab
- [Google Colab](https://colab.research.google.com/notebooks/intro.ipynb) is a free Jupyter notebook environment that requires no setup and runs entirely in the cloud.
