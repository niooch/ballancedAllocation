# Compiler and flags
CXX = g++
CXXFLAGS = -Wall -std=c++11

# Target executable
TARGET = ballsAndBins

# Source files
SRCS = main.cpp

# Object files
OBJS = $(SRCS:.cpp=.o)

# Default target
all: $(TARGET)

# Compile the target executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)

# Compile object files from source files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up build artifacts
.PHONY: clean
clean:
	rm -f $(TARGET) $(OBJS) *.dat
