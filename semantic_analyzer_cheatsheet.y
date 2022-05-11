// ++ and -- operators (both of them is working only on integer values)
expression:
T_ID T_INC
{ 
  /* works only on variables that are declared */ 
  if( symbol_table.count(*$1) == 0 )
  {
    std::stringstream ss;
    ss << "Undeclared variable: " << *$1 << std::endl;
    error( ss.str().c_str() );
  }
  /* works only on variables that has an integer type */
  if(symbol_table[*$1].decl_type != integer)
  {
    std::stringstream ss;
    ss << "Non-integer value can not be incremented!" << std::endl;
    error( ss.str().c_str() );
  }
  /* return type will be integer */
  $$ = new type(integer);
  /* frees the memory */
  delete $1;
}


// for loop (with a syntax like this: for <var> := <expr> to <expr> do <stmts> done)
// tasks to check: variable id declared, with an integer type, both <expr> has an integer type
loop:

