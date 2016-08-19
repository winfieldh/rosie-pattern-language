# coding: utf-8
# #  -*- Mode: Ruby; -*-                                              
# # 
# #  rtest.rb  Sample driver for librosie
# # 
# #  © Copyright IBM Corporation 2016.
# #  LICENSE: MIT License (https://opensource.org/licenses/mit-license.html)
# #  AUTHOR: Jamie A. Jennings


$: << "."                       # add "." to the library search path
require 'rosie'

require 'json'

def print_string_array(retval)
  print "Number of strings returned from api call is: ", retval[:n], "\n"
  ptr_array = FFI::Pointer.new(FFI::Pointer, retval[:ptr]).read_array_of_pointer(retval[:n])
  for i in 0..(retval[:n]-1) do
    str = Rosie::CString.new ptr_array[i]
    print "  [", i, "] len=", str[:len], ", ptr=", str[:ptr].read_string_length(str[:len]), "\n"
  end
end

messages = Rosie::CStringArray.new
engine = Rosie.initialize(Rosie.to_CString("/Users/jjennings/Work/Dev/rosie-pattern-language"), messages)
print_string_array(messages)

config_string = Rosie.to_CString("{\"name\":\"Ruby engine\"}")
print "config_string string: ", config_string[:ptr].read_string_length(config_string[:len]), "\n"
print "config_string length: ", config_string[:len], "\n"
print "config_string struct size: ", Rosie::CString.size, "\n"

config_js = "{\"expression\" : \"[:digit:]+\", \"encode\" : \"json\"}"
config_string = Rosie::to_CString(config_js)

retval = Rosie.configure_engine(engine, config_string)
print_string_array(retval)
Rosie.free_stringArray(retval)

retval = Rosie.inspect_engine(engine)
print_string_array(retval)
Rosie.free_stringArray(retval)

foo = Rosie::to_CString("1239999999")
retval = Rosie.match(engine, foo, nil)
print_string_array(retval)
Rosie.free_stringArray(retval)

retval = Rosie.match(engine, config_string, nil)
print_string_array(retval)
Rosie.free_stringArray(retval)

config_string = Rosie::to_CString("This is NOT valid json")
retval = Rosie.configure_engine(engine, config_string.pointer)
print_string_array(retval)
Rosie.free_stringArray(retval)

retval = Rosie.load_manifest(engine, foo) # should fail
print_string_array(retval)
Rosie.free_stringArray(retval)

retval = Rosie.configure_engine(engine, config_string)
print_string_array(retval)
Rosie.free_stringArray(retval)

# Loop test prep

test = Rosie::to_CString("$sys/MANIFEST")
print "TEST: len=", test[:len], "\n"
print "TEST: string=", test[:ptr].read_string, "\n"

retval = Rosie.load_manifest(engine, test)
print_string_array(retval)
Rosie.free_stringArray(retval)

config_js = "{\"expression\" : \"[:digit:]+\", \"encode\" : \"json\"}"
print "config_js is: ", config_js, "\n"

config_string = Rosie::to_CString(config_js)
retval = Rosie.configure_engine(engine, config_string)
print_string_array(retval)
Rosie.free_stringArray(retval)

foo = Rosie::to_CString("1239999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999")
retval = Rosie.match engine, foo, nil
retval_SAVE = retval

retval = Rosie.match engine, foo, nil
strings = Rosie.from_CStringArray(retval)
code = strings[0]
if code != "true" then
  print "Error code returned from match api"
end
json_string = strings[1]
Rosie.free_stringArray(retval)

if code=="true" then
  print "Successful call to match\n"
else
  print "Call to match FAILED\n"
end

print json_string, "\n"
obj_to_return_to_caller = JSON.parse(json_string)

print " done.\n"
Rosie.finalize(engine)

