#include <gtest/gtest.h>

#include "math/calculator.h"

TEST(CalculatorTest, CalculatorSum) {
    EXPECT_EQ(3, Calculator::Sum(1, 2));
}

TEST(CalculatorTest, CalculatorSub) {
    EXPECT_EQ(-1, Calculator::Sub(1, 2));
}
