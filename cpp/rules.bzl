load("//protobuf:rules.bzl", "proto_compile", "proto_repositories")
load("//cpp:deps.bzl", "DEPS")

def cpp_proto_repositories(
    with_grpc = True,
    lang_deps = DEPS,
    lang_requires = [
      "protobuf",
    ], **kwargs):

  if with_grpc:
    lang_requires += [
      "gtest",
      "protobuf_clib",
      "com_github_grpc_grpc",
      "zlib",
      "nanopb",
      "protoc_gen_grpc_cpp",
      "boringssl",
      "libssl",
      "protocol_compiler",
      "com_github_madler_zlib",
    ]
  proto_repositories(lang_deps = lang_deps,
                     lang_requires = lang_requires,
                     **kwargs)

PB_COMPILE_DEPS = [
    "//external:protobuf",
]

GRPC_COMPILE_DEPS = [
    "//external:protobuf_clib",
    "@com_github_grpc_grpc//:grpc++",
    "@com_github_grpc_grpc//:grpc++_reflection",
]

def cpp_proto_compile(langs = [str(Label("//cpp"))], **kwargs):
  proto_compile(langs = langs, **kwargs)

cc_proto_compile = cpp_proto_compile

def cpp_proto_library(
    name,
    langs = [],
    protos = [],
    imports = [],
    inputs = [],
    proto_deps = [],
    output_to_workspace = False,
    protoc = None,

    pb_plugin = None,
    pb_options = [],

    grpc_plugin = None,
    grpc_options = [],

    proto_compile_args = {},
    with_grpc = False,
    srcs = [],
    deps = [],
    verbose = 0,
    **kwargs):

  if with_grpc:
    if len(langs) == 0:
        langs = [str(Label("//cpp"))]
    compile_deps = GRPC_COMPILE_DEPS
  else:
    if len(langs) == 0:
        langs = [str(Label("//cpp:cpp_no_grpc"))]
    compile_deps = PB_COMPILE_DEPS

  proto_compile_args += {
    "name": name + ".pb",
    "protos": protos,
    "deps": [dep + ".pb" for dep in proto_deps],
    "langs": langs,
    "imports": imports,
    "inputs": inputs,
    "pb_options": pb_options,
    "grpc_options": grpc_options,
    "output_to_workspace": output_to_workspace,
    "verbose": verbose,
    "with_grpc": with_grpc,
  }

  if protoc:
    proto_compile_args["protoc"] = protoc
  if pb_plugin:
    proto_compile_args["pb_plugin"] = pb_plugin
  if grpc_plugin:
    proto_compile_args["grpc_plugin"] = grpc_plugin

  proto_compile(**proto_compile_args)

  native.cc_library(
    name = name,
    srcs = srcs + [name + ".pb"],
    deps = list(set(deps + proto_deps + compile_deps)),
    **kwargs)

# Alias for cpp_proto_library
cc_proto_library = cpp_proto_library
