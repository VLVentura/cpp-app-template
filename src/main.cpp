#include <fmt/format.h>

#include "math/calculator.h"

int main() {
    fmt::print("Sum {}\n", Calculator::Sum(1, 2));
    return 0;
}
