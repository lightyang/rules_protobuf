load("//protobuf:rules.bzl", "proto_compile", "proto_repositories")
load("//python:deps.bzl", "DEPS")
load("//cpp:rules.bzl", "cpp_proto_repositories")

def py_proto_repositories(
    omit_cpp_repositories = False,
    with_grpc = True,
    lang_deps = DEPS,
    lang_requires = [
    ], **kwargs):

  if with_grpc:
    lang_requires += [
      "protoc_gen_grpc_python",
    ]
  if not omit_cpp_repositories:
    cpp_proto_repositories(with_grpc = with_grpc)

  proto_repositories(lang_deps = lang_deps,
                     lang_requires = lang_requires,
                     **kwargs)

def py_proto_compile(
    langs = [],
    with_grpc = True,
    **kwargs):
  if len(langs) == 0:
    if with_grpc:
      langs = [str(Label("//python"))]
    else:
      langs = [str(Label("//python:python_no_grpc"))]
  proto_compile(langs = langs, with_grpc = with_grpc, **kwargs)
