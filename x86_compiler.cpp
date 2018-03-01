#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <unordered_map>


std::vector<std::string> DATA;
int data_number = 0;
std::vector<std::string> CODE;
int code_number = 0;

std::unordered_map<std::string, std::string> data_names;

std::string generate_string_constant(const std::string &str) {
    std::string name("string");
    name.append(std::to_string(data_number++));

    data_names[str] = name;

    std::string data_line;
    data_line.append(name);
    data_line.append(" db ");
    data_line.append("\"");
    data_line.append(str);
    data_line.append("\"");

    DATA.push_back(data_line);

    return name;
}

void generate_print_statement(const std::string &str) {
    std::string name = generate_string_constant(str);
    std::string command("mov ax, OFFSET ");
    command.append(name);
    CODE.push_back(command);
    CODE.push_back("push ax");
    CODE.push_back("call puts");
}

void generate_program() {
    std::cout << ".model small\n.stack 100h\n.data\n";
    for (std::string &data_line: DATA) {
        std::cout << "\n\t" << data_line;
    }

    std::cout << '\n';

    std::ifstream file("io.asm");
    std::stringstream buffer;
    buffer << file.rdbuf();    

    std::cout << buffer.str() << '\n';

    


    for (std::string &code: CODE) {
        std::cout << '\t' << code << '\n';
    }
    std::cout << 
        "; terminate the program\n"
        "\tdone:\n"
        "\t\t; restore the registers\n"
        "\t\tpop ax\n"
        "\t\t; restore the stack registers\n"
        "\t\tmov sp, bp\n"
        "\t\tpop bp\n"
        "\t\t; exit the program\n"
        "\t\tmov ax, 4c00h\n"
        "\t\tint 21h\n"
        "\tEND main\n";
}

int main() {
    generate_print_statement("Hello World!");
    generate_print_statement("My name is mathew");
    generate_program();
    
}