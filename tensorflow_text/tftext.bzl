"""
Build rule for open source tf.text libraries.
"""

def py_tf_text_library(
    name,
    srcs = [],
    deps = [],
    visibility = None,
    cc_op_defs = [],
    cc_op_kernels = []):
  """Creates build rules for TF.Text ops as shared libraries.

  Defines three targets:

  <name>
      Python library that exposes all ops defined in `cc_op_defs` and `py_srcs`.
  <name>_cc
      C++ library that registers any c++ ops in `cc_op_defs`, and includes the
      kernels from `cc_op_kernels`.
  python/ops/_<name>.so
      Shared library exposing the <name>_cc library.

  Args:
    name: The name for the python library target build by this rule.
    srcs: Python source files for the Python library.
    deps: Dependencies for the Python library.
    visibility: Visibility for the Python library.
    cc_op_defs: A list of c++ src files containing REGISTER_OP definitions.
    cc_op_kernels: A list of c++ targets containing kernels that are used
        by the Python library.
  """
  binary_name = "python/ops/_" + cc_op_kernels[0][1:] + ".so"
  if cc_op_defs:
    binary_name = "python/ops/_" + name + ".so"
    library_name = name + "_cc"
    native.cc_library(
        name = library_name,
        srcs = cc_op_defs,
        copts = [ "-pthread", "-std=c++11", ],
        alwayslink = 1,
        deps = cc_op_kernels + [
            "@local_config_tf//:libtensorflow_framework",
            "@local_config_tf//:tf_header_lib",
        ],
    )

    native.cc_binary(
        name = binary_name,
        copts = [ "-pthread", "-std=c++11", ],
        linkshared = 1,
        deps = [
            ":" + library_name,
        ],
    )

  if srcs:
    native.py_library(
        name = name,
        srcs = srcs,
        srcs_version = "PY2AND3",
        visibility = visibility,
        data = [ ":" + binary_name ],
        deps = deps,
    )
