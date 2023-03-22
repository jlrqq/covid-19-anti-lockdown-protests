#!/bin/bash

# Go to the lambda function directory
cd ../code/lambda_function_reddit/

if [ -f lambda_function_reddit.zip ]; then
  rm lambda_function_reddit.zip
fi

# Check if requirements.txt exists
if [ -f requirements.txt ]; then
  # Install packages from requirements.txt into a directory called package
  mkdir -p package
  python3 -m venv venv
  source venv/bin/activate
  pip3 install -r requirements.txt --target ./package/
else
  # Return an error and stop execution if requirements.txt does not exist
  echo "Error: requirements.txt not found"
  exit 1
fi

#copy all files and lambda_function_reddit.py inside package to a temp folder
mkdir -p package_temp
cp -r package/* package_temp
cp lambda_function_reddit.py package_temp
rm -r ./package_temp/pandas ./package_temp/numpy ./package_temp/*.dist-info

unzip ../numpy-1.24.2-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -d ./package_temp
unzip ../pandas-1.5.3-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -d ./package_temp
rm -r ./package_temp/*.dist-info

# Zip the lambda_function_reddit.py file and all files inside ./package
cd package_temp

zip -r ../lambda_function_reddit.zip ./*

cd ..
# Remove the virtual environment folder
rm -rf venv
rm -rf package
rm -rf package_temp

#write a loop to check if lambda_function_reddit.zip exist. after 30 secs still not found stop all execution
for i in {1..30}
do
  if [ -f lambda_function_reddit.zip ]; then
    break
  else
    sleep 1
  fi
done