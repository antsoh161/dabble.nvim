local M = {}

M.default = {
  cpp = [[
#include <iostream>

int main() {
    std::cout << "dabbling" << std::endl;
    return 0;
}
]],
  python3 = [[
def main():
    print("dabbling")

if __name__ == "__main__":
    main()
]],
}

return M
