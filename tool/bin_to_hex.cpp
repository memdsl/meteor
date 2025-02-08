#include <fstream>
#include <iostream>
#include <stack>
#include <string>

using namespace std;

class BinToHex {
    public:
         BinToHex();
        ~BinToHex();
    public:
        void convertData();
        void convertData(int argc, char *argv[]);
        void handleInputArgs(int argc, char *argv[]);
        void printfErrorInfo(const string & err);
    private:
        string   c_file_srcs;
        string   c_file_dest;
        string   c_file_deft = "inst.data";
        ifstream c_fint;
        ofstream c_fout;
};

BinToHex::BinToHex() {};

BinToHex::~BinToHex() {};

void BinToHex::convertData() {
    c_fint.open(c_file_srcs);
    if (!c_fint) {
        cout << "[error]: failed to open srcs file [" << c_file_srcs << "]" << endl;;
        exit(-1);
    }
    c_fout.open(c_file_dest);
    if (!c_fout) {
        cout << "[error]: failed to open dest file [" << c_file_srcs << "]" << endl;
        exit(-1);
    }
    c_fout << hex;

    char            t_ch;
    int             t_cnt = 0;
    std::stack<int> t_hex_stack;

    while(c_fint.get(t_ch)) {
        t_cnt++;
        int t_hex = static_cast<unsigned char>(t_ch);
        t_hex_stack.push(t_hex);
        if(t_cnt % 4 == 0) {
            while (t_hex_stack.size() != 0) {
                t_hex = t_hex_stack.top();
                if (t_hex < 0x10) {
                    c_fout << '0';
                }
                c_fout << t_hex;
                t_hex_stack.pop();
            }
            c_fout << endl;
        }
    }
    c_fint.close();
    c_fout.close();
}

void BinToHex::convertData(int argc, char *argv[]) {
    handleInputArgs(argc, argv);
    convertData();
}

void BinToHex::handleInputArgs(int argc, char *argv[]) {
    if (argc == 1) {
        return;
    }
    if (string(argv[1]) == "-o") {
        if(argc > 4) {
            printfErrorInfo("[error]: arguments is more than ecpected!");
        }
        else if(argc < 4) {
            printfErrorInfo("[error]: arguments is less than expected!");
        }
        else {
            c_file_srcs = argv[3];
            c_file_dest = argv[2];
        }
    }
    else {
        if (argc > 2) {
            printfErrorInfo("[error]: arguments is more than ecpected!");
        }
        else if (argc < 2) {
            printfErrorInfo("[error]: arguments is less than expected!");
        }
        else {
            c_file_srcs = argv[1];
            c_file_dest = c_file_deft;
        }
    }
}

void BinToHex::printfErrorInfo(const string &err) {
    cout << err << "\n" << endl;
    cout << "[usage]: bin_to_mem -o xxx.data xxx.bin" << endl;
    cout << "[usage]: bin_to_mem             xxx.bin" << ", "         <<
            "[if no output file is set, the default output file is '" <<
            c_file_deft << "']" << endl;
    exit(-1);
}

int main(int argc, char *argv[]) {
    BinToHex binToMem;
    binToMem.convertData(argc, argv);
}
