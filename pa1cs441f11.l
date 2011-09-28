%{
    #include <ctime>
    #include <iostream>
    #include <string>
    #include <sstream>
    #include <list>
    #include <fstream>
    #include <streambuf>
    #include <map>
    #include <set>
    using namespace std;

    stringstream output;  //holds html until we are ready to write to file
    map<string, set<int> > var_list; //variable index
%}

operator ("="|"+"|"-"|"/"|"*"|"<="|">="|"<"|">"|"("|")"|"{"|"}"|";")
number [\-+]?[0-9]+(.[0-9]+)?
%%
%{
    int nline = 0;
%}
^.*\n                   { nline++; output << "<tr><td class=\"line_number\"><a name=\"" << nline << "\">" << nline << "</a></td><td>"; REJECT; }
'([^']|'')*'            { output << "<span class=\"STRINGLITERAL\">" << yytext << "</span>"; }
"/*"[^"*/"]*"*/"        { output << "<tr><td><span class=\"COMMENT\">" << yytext << "</span>"; }
"//"[^\n]*              { output << "<span class=\"COMMENT\">" << yytext << "</span>"; }
{number}                { output << "<span class=\"NUMBER\">" << yytext << "</span>"; }
[a-zA-Z][a-zA-Z0-9]*    { 
                            output << "<span class=\"IDENTIFIER\">" << yytext << "</span>";
                            var_list[yytext].insert(nline);
                        }
{operator}              { output << "<span class=\"OPERATOR\">" << yytext << "</span>"; }
[ ]                     { output << "&nbsp;"; }
[\t]                    { output << "&nbsp;&nbsp;&nbsp;&nbsp;"; }
\n                      { output << "</td></tr>" << endl; }
%%

int yywrap(void){
    return 1;
}

int main(int argc, char *argv[]){
    time_t current_time = time(0);

    //If file given as input, continue
    if(argc >= 2){
        FILE *myfile = fopen(argv[1], "r");

        // make sure it's valid:
        if (!myfile) {
            output << "I can't open " << argv[1] << "!" << endl;
            return -1;
        }
        // set lex to read from it instead of defaulting to STDIN:
        yyin = myfile;

        //read in stylesheet
        ifstream t("stylesheet.css");
        string stylesheet((std::istreambuf_iterator<char>(t)),std::istreambuf_iterator<char>());

        //Create html
        output << "<html>" << endl;
        output << "  <head>" << endl;
        output << "  <style type=\"text/css\">" << endl;
        output << "    " << stylesheet << endl;
        output << "  </style>" << endl;
        output << "  </head>" << endl;
        output << "  <body>" << endl;
        output << "    <div class=\"header\">" << endl;
        output << "      <p><b>Parsed file: </b>" << argv[1] << "</p>" << endl;
        output << "      <p><b>Parser written by: </b>Robert Nolan</p>" << endl;
        output << "      <p><b>Parsed at time: </b>" << ctime(&current_time) << "</p>" << endl;
        output << "    </div>" << endl;
        output << "    <table class=\"code\">" << endl;
        output << "      <tr><th>#</th><th>Code</th></tr>" << endl;
        output << yylex() << endl;
        output << "    </table>" << endl;
        output << "    <table class=\"var_list\">" << endl;
        output << "      <tr><th>Variable</th><th>Line Numbers</th></tr>" << endl;
        
        for( map<string,set<int> >::iterator iter = var_list.begin(); iter != var_list.end(); iter++ ){
            output << "      <tr>" << endl;
            output << "        <td>" << iter->first << "</td>" << endl;
            output << "        <td>";
            for(set<int>::iterator j = iter->second.begin(); j != iter->second.end(); j++){
                output << "<a href=\"#" << *j << "\">" << *j << ",</a> ";
            }
            output << "</td>" << endl;
            output << "      </tr>" << endl;
        }
        output << "    </table>" << endl;
        output << "  </body>" << endl;
        output << "</html>" << endl;

        //Finally write to output file.
        string output_name(argv[1]);

        output_name = output_name.substr(0, output_name.find_last_of(".") + 1);
        output_name += "html";

        cout << "Outputing to " << output_name << endl;
        ofstream outFile;
        outFile.open(output_name.c_str());
        outFile << output.rdbuf();
        outFile.close();
    }else{
        output << "<html><body><h1>No input file given.</h1></body></html>";
    } 
   
    return 0;
}


