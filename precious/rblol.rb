require 'yaml'

arr = YAML.load(File.read("/home/henry/dependencies.yml"))

p arr 
