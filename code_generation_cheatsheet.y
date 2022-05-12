/* For code generation for compilers we use assembly language. Idea: 
In assembly you don't have loops, but you can achieve the same thing with 
jump statements. in C++, in a for loop statement, you do the things inside 
the loop, increment the counter, evaluate if the loop should end or not and 
then repeat the process. all that is done with the special syntax. 
In assembly you have to do those things explicitly, declare where the loop 
starts (start label), do the things inside ($6->expr_code), check if the 
loop should end (cmp eax ...), if so, exit the loop (jump end), otherwise 
increase the counter (inc dword ...) and start the loop again (jmp start). */

// task: add code generation support for the "++" and "--" operators.
expression:
T_ID T_INC
{ 
  /* semantic starts */ 
  if( symbol_table.count(*$1) == 0 )
  {
    std::stringstream ss;
    ss << "Undeclared variable: " << *$1 << std::endl;
    error( ss.str().c_str() );
  }
  if (symbol_table[*$1].decl_type != integer)
  {
    std::stringstream ss;
    ss << "Non-integer value can not be incremented!" << std::endl;
    error( ss.str().c_str() );
  }
  /* semantic ends */ 
  /* code generation starts */ 
  $$ = new expression_descriptor(integer, "mov eax, ["+symbol_table[*$1].label+"]\n" +
                                          // copy address into eax
                                          "add eax, 1\n" +
                                          // increment eax by 1
                                          "mov ["+symbol_table[*$1].label+"], eax\n");
                                          // copy eax into address
                                          // now the ID got increased by 1.
  /* code generation ends */ 
  delete $1;
}

T_ID T_DEC
{
    if( symbol_table.count(*$1) == 0 )
    {
      std::stringstream ss;
      ss << "Undeclared variable: " << *$1 << std::endl;
      error( ss.str().c_str() );
    }
    if (symbol_table[*$1].decl_type != integer)
    {
      std::stringstream ss;
      ss << "Non-integer value can not be decremented!" << std::endl;
      error( ss.str().c_str() );
    }
    $$ = new expression_descriptor(integer, "mov eax, ["+symbol_table[*$1].label+"]\n" +
                                            "sub eax, 1\n" +
                                            "mov ["+symbol_table[*$1].label+"], eax\n");
    delete $1;
}


// task. add code generation support for the newly introduced "for loop"
loop:
T_FOR T_ID T_ASSIGN expression T_TO expression T_DO statements T_DONE
// for i := 1+2 to 3+4 do i:i+1 done
{
    if( symbol_table.count(*$2) == 0 )
    {
        std::stringstream ss;
        ss << "Undeclared variable: " << *$2 << std::endl;
        error( ss.str().c_str() );
    }
    if(symbol_table[*$2].decl_type != integer || $4->expr_type != integer || $6->expr_type != integer)
    {
       std::stringstream ss;
       ss << d_loc__.first_line << ": Type error." << std::endl;
       error( ss.str().c_str() );
    }
    std::string start = new_label();
    std::string end = new_label();
    $$ = new std::string("" +
            $4->expr_code +
            // eval 1+2 into eax register, now eax = 3
            "mov [" + symbol_table[*$2].label + "], eax\n" +
            // i := eax(which is 3), now i = 3
            start + ":\n" +
            // start the loop 
            $6->expr_code +
            // eval 3+4 into eax, now eax = 7
            "cmp eax, [" + symbol_table[*$2].label + "]\n" +
            // eax == i ? => check if 3 is equal to 7
            "jb near " + end + "\n" +
            // if true end the loop
            *$8 +
            // exec i:= i + 1
            "inc dword [" + symbol_table[*$2].label + "]\n" +
            // inc DWORD PTR [var] — add one to the 32-bit integer stored at location var
            "jmp " + start + "\n" +
            // go to the start of the loop
            end + ":\n");
    delete $2;
    delete $4;
    delete $6;
    delete $8;
}
