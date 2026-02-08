#include <iostream>
#include <unistd.h>
#include <ctime>

int main() {
    time_t now = time(nullptr);
    std::cout << "========================================" << std::endl;
    std::cout << "服务启动时间: " << ctime(&now);
    std::cout << "服务运行中... PID: " << getpid() << std::endl;
    std::cout << "========================================" << std::endl;

    int count = 0;
    while (true) {
        count++;
        std::cout << "运行中... 第 " << count << " 分钟" << std::endl;
        sleep(60);
    }

    return 0;
}
