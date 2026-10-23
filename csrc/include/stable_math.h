#pragma once

#include <algorithm>
#include <cmath>
#include <cstdint>

namespace mlstm_cpu {

inline float log_sigmoid_stable(float x) {
  if (x >= 0.0f) {
    return -std::log1p(std::exp(-x));
  }
  return x - std::log1p(std::exp(x));
}

inline float inv_sqrt_dim(int64_t dim) {
  return 1.0f / std::sqrt(static_cast<float>(dim));
}

}  // namespace mlstm_cpu

