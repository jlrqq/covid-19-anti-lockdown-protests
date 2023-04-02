#!/bin/bash

# Go to the lambda function directory
cd ../code/${function_name}/

if [ -f ${function_name}.zip ]; then
  rm ${function_name}.zip
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
  echo "requirements.txt not found"
  exit 1
fi

#copy all files and ${function_name}.py inside package to a temp folder
mkdir -p package_temp
cp -r package/* package_temp
cp ${function_name}.py package_temp

#check if directory named pandas and numpy both exist inside package_temp folder
if [ -d ./package_temp/pandas ] && [ -d ./package_temp/numpy ]; then
  rm -r ./package_temp/pandas ./package_temp/numpy
  unzip ../numpy-1.24.2-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -d ./package_temp
  unzip ../pandas-1.5.3-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -d ./package_temp
else
  echo "pandas or numpy not found"
fi


rm -r ./package_temp/*.dist-info

# Zip the ${function_name}.py file and all files inside ./package
cd package_temp

zip -r ../${function_name}.zip ./*

cd ..
# Remove the virtual environment folder
rm -rf venv
rm -rf package
rm -rf package_temp

#write a loop to check if ${function_name}.zip exist. after 30 secs still not found stop all execution
for i in {1..30}
do
  if [ -f ${function_name}.zip ]; then
    break
  else
    sleep 1
  fi
done