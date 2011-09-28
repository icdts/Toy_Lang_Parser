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

    map<string, set<int> > var_list;
    set<string> key_list;
%}

operator ("="|"+"|"-"|"/"|"*"|"<="|">="|"<"|">"|"("|")"|"{"|"}"|";")
number [\-+]?[0-9]+(.[0-9]+)?
%%
%{
    int nline = 0;
%}
^.*\n                   { nline++; cout << "<tr><td class=\"line_number\"><a name=\"" << nline << "\">" << nline << "</a></td><td>"; REJECT; }
'([^']|'')*'            { cout << "<span class=\"STRINGLITERAL\">" << yytext << "</span>"; }
"/*"[^"*/"]*"*/"        { cout << "<span class=\"COMMENT\">" << yytext << "</span>"; }
"//"[^\n]*              { cout << "<span class=\"COMMENT\">" << yytext << "</span>"; }
{number}                { cout << "<span class=\"NUMBER\">" << yytext << "</span>"; }
[a-zA-Z][a-zA-Z0-9]*    { 
                            cout << "<span class=\"IDENTIFIER\">" << yytext << "</span>";
                            var_list[yytext].insert(nline);
                            key_list.insert(yytext);
                        }
{operator}              { cout << "<span class=\"OPERATOR\">" << yytext << "</span>"; }
[ ]                     { cout << "&nbsp;"; }
[\t]                    { cout << "&nbsp;&nbsp;&nbsp;&nbsp;"; }
\n                      { cout << "</td></tr>" << endl; }
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
            cout << "I can't open " << argv[0] << "!" << endl;
            return -1;
        }
        // set lex to read from it instead of defaulting to STDIN:
        yyin = myfile;

        //read in stylesheet
        ifstream t("stylesheet.css");
        string stylesheet((std::istreambuf_iterator<char>(t)),std::istreambuf_iterator<char>());

        cout << "<html>" << endl;
        cout << "  <head>" << endl;
        cout << "  <style type=\"text/css\">" << endl;
        cout << "    " << stylesheet << endl;
        cout << "  </style>" << endl;
        cout << "  </head>" << endl;
        cout << "  <body>" << endl;
        cout << "    <div class=\"header\">" << endl;
        cout << "      <p><b>Parser written by: </b>Robert Nolan</p>" << endl;
        cout << "      <p><b>Parsed at time: </b>" << ctime(&current_time) << "</p>" << endl;
        cout << "    </div>" << endl;
        cout << "    <table class=\"code\">" << endl;
        cout << "      <tr><th>#</th><th>Code</th></tr>" << endl;
        cout << yylex() << endl;
        cout << "    </table>" << endl;
        cout << "    <table class=\"var_list\">" << endl;
        cout << "      <tr><th>Variable</th><th>Line Numbers</th></tr>" << endl;
        
        for( map<string,set<int> >::iterator iter = var_list.begin(); iter != var_list.end(); iter++ ){
            cout << "      <tr>" << endl;
            cout << "        <td>" << iter->first << "</td>" << endl;
            cout << "        <td>";
            for(set<int>::iterator j = iter->second.begin(); j != iter->second.end(); j++){
                cout << "<a href=\"#" << *j << "\">" << *j << ",</a> ";
            }
            cout << "</td>" << endl;
            cout << "      </tr>" << endl;
        }
        cout << "    </table>" << endl;
        cout << "  </body>" << endl;
        cout << "</html>" << endl;
    }else{
        cout << "<html><body><h1>No input file given.</h1></body></html>";
    }
    return 0;
}


