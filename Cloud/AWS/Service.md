- [Synopsis](#synopsis)
- [Shared Responsibility Model](#shared-responsibility-model)
- [Versioning](#versioning)

Computer Vision
- Rekognition:
    - facial comparison and analysis
    - object detection and labeling
    - text detection
    - content moderation

Text and Document Analysis
- Textract: extract text, handwriting, layout elements, and data from scanned documents
- Comprehend: extract key phrases, entities, and sentiment

Language AI
- Lex: conversational voice and text
- Transcribe: converts speech to text
- Polly: convert text to speech

Customer Experience
- Kendra: intelligent document search
- Personalize: personalized product recommendations
- Translate: translates between 75 languages

Business Metrics
- Forecast: predicts future points in time-series data
- Fraud Detector:
    - detects fraud and fraudulent activities
    - checks online transactions, product reviews, checkout and payments, new accounts, and account takeover

Generative AI
- Bedrock:
    - foundation models
    - can customize with training data or RAG

## Synopsis
- __Audit Manager__: provides automatic evidence collection to help with continually audit AWS usage
- __Augmented AI__: Amazon A2I provides built-in human review workflows for common ML use cases
- __Artifact__: provides access to AWS security and compliance documentation, reports which are produced by third-party auditors regarding security controls maintained by AWS
- __Bedrock__: provides access to high-performing foundation models (FMs) and a set of tools to customize, evaluate, and safeguard the models
    - __Agent__: a feature to use when create generative AI applications, which can automatically call Amazon Bedrock APIs and can enhance foundation model (FM) performance
    - __Guardrails__: filter out unwanted topics or content and add safeguards to the model, which is used to adopt generative AI in a safe and responsible way with minimal operational overhead
    - __Knowledge Bases__:
        - provide fully managed support to update foundation models (FMs) with up-to-date and proprietary information
        - design conversational solutions based on proprietary data
- __CloudWatch__: a centralized logging service that monitors AWS resources and stores application logs and performance metrics
- __CloudTrail__: provide risk auditing by capturing API calls that are made to AWS services
- __Comprehend__: detect and extract insights, key phrases, and sentiment from documents
- __Config__: provide an overview of your AWS resource configurations, which can identify settings that do not meet compliance standards
- __Inferentia__: is a type of accelerator that delivers high performance in Amazon EC2
- __Inspector__: is an automated vulnerability management service, which scans AWS workloads for software vulnerabilities or unintended network exposure
- __Kendra__: an intelligent search service that indexes a set of documents, which identifies relevant documents based on semantic search
- __Key Management Service__: store and manage cryptographic keys for data protection, which creates and controls the keys to encrypt data at rest and in transit
- __Lex__: use to build conversational interfaces with voice and text
- __Macie__: discover and monitor sensitive data in Amazon S3 buckets, which provides insights into data security risks by using ML-based pattern matching to discover sensitive data and to help mitigate risks
- __OpenSearch Service__: use to deploy and manage OpenSearch clusters, which stores vector embeddings and to perform searches on stored embeddings, semantic search can be used to identify the meaning, context, and intent of a query
- __Polly__: uses deep learning technologies to synthetize natural-sounding speech
- __Personalize__: uses customer data to generate personalized product or content recommendations
- __(Amazon) Q__: is generative AI assistant that you g can use to answer business questions and solve problems
    - __Q Business__: is a generative AI–powered assistant that can answer questions, provide summaries, generate content, and securely complete tasks based on data and information in company systems
    - __Q Developer__: is a generative AI assistant that can help you understand, build, extend, and operate AWS applications
    - __Q in QuickSight__: provide the ability to query a data source in natural language and produce charts or plots
- __Rekognition__: provides image and video analysis to add computer vision capabilities to applications
- __SageMaker__: use to build, train, and deploy ML models
    - __Autopilot__: automates the creation, training, and tuning of ML models, which helps to  develop high-quality models with minimal effort
    - __BlazingText__: an algorithm provides highly optimized implementations of the word2vec algorithm for classification problems
    - __Canvas__: build/create ML models/solutions without the need to write code
    - __Clarify__: runs processing jobs that analyze both training data and inference endpoints for bias and explainability, which creates reports based on bias
    - __Data Wrangler__: has a graphical UI and is a low-code no-code (LCNC) solution for data cleansing and preparation
    - __Experiments__:  a capability of SageMaker that you can use to create, analyze, and manage ML experiments
    - __Feature Store__: create, store, share, and manage features that are used in ML models
    - __Ground Truth__: uses a human workforce to label data that you can then use for ML model training
    - __JumpStart__: is an ML hub that provides access to pre-trained, open source models
    - __Feature Store__: a centralized repository to store, retrieve, and share ML features
    - __Model Cards__: document critical details (like training details, evaluation metrics and model performance) about ML models in a single location, which offer risk rating as a built-in metric for tracking and viewing
    - __Model Monitor__: continuously monitors the performance of deployed ML models, monitors models in an environment and searches for deviations
    - __Model Registry__: a centralized repository to organize, manage, and version ML models, as well as to catalog models and capture metadata
    -  __Pipelines__: provide a framework to orchestrate the ML model development workflow, create consistent, repeatable, and scalable ML operations, create a directed acyclic graph (DAG) to define the continuous integration and continuous delivery (CI/CD) pipeline
    - __Serverless Inference__: runs model on a Lambda function that incurs charges only for the length of time that it runs
- __Secrets Manager__: store, manage and maintain credentials or tokens, which helps to improve security by rotating the keys and tokens used in AWS environment
- __Serverless Application Model__ (SAM): define application infrastructure code and management of serverless applications through the entire development lifecycle, focuses on the infrastructure necessary to build and run serverless applications
- __Textract__: automatically extracts text and data from images and documents
- __Transcribe__: provides automatic speech recognition capabilities
- __Trusted Advisor__: provides resources and recommendations for cost optimization, security, and resilience, which evaluates AWS environment, compares environment settings with best practices, and recommends actions to remediate any deviation from best practices


Networking:
- __Gateway Endpoint__: provides a secure connection from a VPC to Amazon S3 or Amazon DynamoDB, which provides connectivity to Amazon S3 from a VPC, ensures that data that is transferred between the EC2 instances and Amazon S3 stays within the AWS network and does not traverse the internet
- __Transit Gateway__: connect multiple VPCs together to make the VPCs act as a single network and streamline network traffic.


## Shared Responsibility Model
Customer: responsible for security in the cloud
- customer data
- platform, applications, identity and access management
- operating systems, network and firewall configuration
- client-side data, encryption, and data integrity authentication
- server-side encryption
- networking traffic protection

AWS: responsible for security of the cloud
- software
- compute, storage, database, networking
- hardware, AWS global infrastructure
- regions, availability zones, edge locations


## Versioning
Where Versioning code can be applied:
- CodeCommit: code
- S3: dataset
- ECR: container
- other: training job, model, endpoint
