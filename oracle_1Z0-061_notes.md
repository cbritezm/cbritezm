# Introduction

I have compiled these notes whilst revising for the Oracle [1Z0-061](https://education.oracle.com/pls/web_prod-plq-dad/db_pages.getpage?page_id=5001&get_params=p_exam_id:1Z0-061) Exam - Oracle Database 12c: SQL Fundamentals. They should also be relevant to the [1Z0-051](https://education.oracle.com/pls/web_prod-plq-dad/db_pages.getpage?page_id=5001&get_params=p_exam_id:1Z0-051) - Oracle Database 11g: SQL Fundamentals exam. Revision was most conducted using the excellent and highly recommended "[OCA Oracle Database 12c SQL Fundamentals I Exam Guide](http://www.amazon.com/Oracle-Database-Fundamentals-Guide-1Z0-061/dp/0071820280)" by Roopesh Ramklass.

I have aimed to include include in these notes common "gotchas" and easy to forget functionality rather than documenting everything required for the exam. This can then be used as a quick refresher before walking into the exam.

The content is broken up into sections with each heading mapping to the relevant [Oracle 1Z0-061 exam topics](https://education.oracle.com/pls/web_prod-plq-dad/db_pages.getpage?page_id=5001&get_params=p_exam_id:1Z0-061).

# Describe the features of Oracle Database 12c

* The DML (data manipulation language) commands are: `SELECT`, `INSERT`, `UPDATE`, `DELETE` and `MERGE`.
* The DDL (data definition language) commands are: `CREATE`, `ALTER`, `DROP`, `RENAME`, `TRUNCATE` and `COMMENT`.
* The DCL (data control language) command are: `GRANT` and `REVOKE`.
* The TCL (transaction control language) commands are: `COMMIT`, `ROLLBACK` and `SAVEPOINT`.

# Retrieving Data using the SQL SELECT Statement

* Concatenation with NULL is OK.

  ```sql
  'Mike'||NULL||'Leonard' = 'MikeLeonard'
  ```
* Expressions with NULL always result in NULL.

  ```sql
  1 + 2 * NULL + 3 = NULL
  ```
* Operator precedences are shown in the following list, from highest precedence to the lowest. Operators that are shown together on a line have the same precedence.

  ```
  INTERVAL
  !
  - (unary minus), ~ (unary bit inversion)
  ^
  *, /, DIV, %, MOD
  -, +
  &
  |
  = (comparison), <=>, >=, >, <=, <, <>, !=, IS, LIKE, REGEXP, IN
  BETWEEN, CASE, WHEN, THEN, ELSE
  NOT
  AND, &&
  XOR
  OR, ||
  ```

# Restricting and Sorting Data

* `BETWEEN` is inclusive.

# Using Single-Row Functions to Customize Output

* `TRIM` by default trims whitespace.
* To `TRIM` other characters use the following syntax.

  ```sql
  TRIM('#' from '#MYSTRING#')
  ```
* `LEADING`, `TRAILING` or `BOTH` can be specified in `TRIM` to control where the characters are trimmed from.

  ```sql
  TRIM(TRAILING '#' from '#MYSTRING#')
  TRIM(LEADING '#' from '#MYSTRING#')
  TRIM(BOTH '#' from '#MYSTRING#') -- This is the default.
  ```
* `MONTHS_BETWEEN` works backwards, that is a positive number is returned when the first argument is greater than the second.

  ```sql
  MONTHS_BETWEEN('01-JAN-15', '01-FEB-15') = -1
  MONTHS_BETWEEN('01-FEB-15', '01-JAN-15') = 1
  ```
* If `INSTR` does not find the target string 0 is returned.

  ```sql
  INSTR('a', 'b') = 0
  ```
* You can `ROUND` to nearest whole numbers (least significant digit is 0).

  ```sql
  ROUND(1584.73, -3) = 2000
  ROUND(11, -1) = 10
  ```
* `TRUNC` of a `NUMBER` works like rounding down.

  ```sql
  TRUNC(1256.56, 1) = 1256.5
  ROUND(1256.56, 1) = 1256.6

  TRUNC(1256.56, -2) = 1200
  ROUND(1256.56, -2) = 1300
  ```
* `LPAD`/`RPAD` take an argument specifying the resultant length **not** how much to append:.

  ```sql
  LPAD('A', 4, '.') = '...A'
  RPAD('A', 4, '.') = 'A...'
  ```
* `NULLIF` returns the first argument if the two arguments don't match else it returns `NULL`.

  ```sql
  NULLIF('a', 'a') = NULL
  NULLIF('a', 'b') = 'a'
  ```
* Single row numeric functions **always** return a numeric value. These are the only group of functions that do this.

# Using Conversion Functions and Conditional Expressions

* Format masks behave differently when operating on numbers or characters.

  ```sql
  TO_NUMBER(1234.49, 999999.9) -- Raises an exception ORA_01722: invalid number
  TO_CHAR(1234.49, '999999.9') = 1234.5 -- Note the rounding
  ```
* The default Oracle data format mask is `DD-MON-RR`.
* ,/. and D/G style number separators cannot be mixed in the same format mask.

## Format masks

### Numeric Format masks

| Format Element  | Description                                                | Format       | Number  | Character Result                             |
|-----------------|------------------------------------------------------------|--------------|---------|----------------------------------------------|
| 9               | Numeric width                                              | 9999         | 12      | 12                                           |
| 0               | Displays leading zeros                                     | 09999        | 0012    | 00012                                        |
| .               | Position of decimal point                                  | 09999.999    | 030.40  | 00030.400                                    |
| D               | Decimal separator position (period is default)             | 09999D999    | 030.40  | 00030.400                                    |
| ,               | Position of commas symbol                                  | 09999,999    | 03040   | 00003,040                                    |
| G               | Group separator position (comma is default)                | 09999G999    | 03040   | 00003,040                                    |
| $               | Dollar sign                                                | $099999      | 03040   | $003040                                      |
| L               | Local currency                                             | L099999      | 03040   | GBP003040 if nls_currency is set to GBP      |
| MI              | Position of minus sign for negatives                       | 99999MI      | -3040   | 3040-                                        |
| PR              | Wrap negatives in parentheses                              | 99999PR      | -3040   | <3040>                                       |
| EEEE            | Scientific notation                                        | 99.99999EEEE | 121.976 | 1.21976E+02                                  |
| U               | nls_dual_currency                                          | U099999      | 03040   | CAD003040 if nls_dual_currency is set to CAD |
| V               | Multiplies by 10n times (n is the number of nines after V) | 9999V99      | 3040    | 304000                                       |
| S               | + or - sign is prefixed                                    | S999999      | 3040    | +3040                                        |

### Date Format Masks

| Format Element | Description                              | Result                |
|----------------|------------------------------------------|-----------------------|
| Y              | Last digit of year                       | 5                     |
| YY             | Last two digits of year                  | 75                    |
| YYY            | Last three digits of year                | 975                   |
| YYYY           | Four-digit year                          | 1975                  |
| RR             | Two-digit year                           | 75                    |
| YEAR           | Case-sensitive English spelling of year  | NINETEEN SEVENTY-FIVE |
| MM             | Two-digit month                          | 06                    |
| MON            | Three-letter abbreviation of month       | JUN                   |
| MONTH          | Case-sensitive English spelling of month | JUNE                  |
| D              | Day of week                              | 2                     |
| DD             | Two-digit day of month                   | 02                    |
| DDD            | Day of the year                          | 153                   |
| DY             | Three-letter abbreviation of day         | MON                   |
| DAY            | Case-senstitive English spelling of day  | MONDAY                |

### Less Commonly Used Date Format Masks

| Format Element               | Description                                               | Result                      |
|------------------------------|-----------------------------------------------------------|-----------------------------|
| W                            | Week of month                                             | 4                           |
| WW                           | Week of year                                              | 39                          |
| Q                            | Quarter of year                                           | 3                           |
| CC                           | Century                                                   | 10                          |
| S preceding CC, YYYY or YEAR | If date is BC, a minus sign is prefixed to result         | -10, -1000 or -ONE THOUSAND |
| IYYY,IYY,IY,I                | ISO dates of four, three, two and one digit, respectively | 1000, 000, 00, 0            |
| BC, AD, B.C. and A.D.        | BC or AD and periodspaced B.C. or A.D.                    | BC                          |
| J                            | Julian day - days since 31 December 4713 BC               | 1356075                     |
| IW                           | ISO standard week (1 to 53)                               | 39                          |
| RM                           | Roman numeral month                                       | IX                          |

### Date Form Masks for Time Components

| Format Element        | Description                            | Result     |
|-----------------------|----------------------------------------|------------|
| AM, PM, A.M. and P.M. | Meridian indicators                    | PM         |
| HH, HH12 and HH24     | Hour of day, 1-2 hours, and 0-23 hours | 09, 09, 21 |
| MI                    | Minute (0-59)                          | 35         |
| SS                    | Second (0-59)                          | 13         |
| SSSSS                 | Seconds past midnight (0-86399)        | 77713      |

### Miscellaneous Date Format Masks

| Format Element          | Description                                          | Result                            |
|-------------------------|------------------------------------------------------|-----------------------------------|
| -/.,?#!                 | Punctuation marks: 'MM.YY'                           | 09.08                             |
| "any character literal" | Character literals: '"Week" W "of" Month'            | Week 2 of September               |
| TH                      | Positional or ordinal text: 'DDth "of" Month'        | 12th of September                 |
| SP                      | Spelled out number: 'MmSP Month Yyyysp'              | Nine September Two Thousand Eight |
| THSP or SPTH            | Spelled out positional or ordinal number: 'hh24SpTh' | Fourteenth                        |


# Reporting Aggregated Data Using the Group Functions

* `COUNT(ALL *)` is default and the same as `COUNT(*)`.
* Group functions ignore NULLs.
* As group functions ignore NULLs beware that `COUNT(DISTINCT colname)` will not count any rows with NULL in `colname`.
* Group functions can only be nested two levels deep.
* `HAVING` can come before or after the `GROUP BY`.
* `GROUP BY` and `DISTINCT` can, in some cases, be used to create the same results. The following are equivialent.

  ```sql
  SELECT comm
  FROM scott.emp
  GROUP BY comm;

  SELECT DISTINCT comm
  FROM scott.emp;
  ```

# Displaying Data From Multiple Tables Using Joins

* `NATURAL JOIN` joins tables using columns with identical names.
* A `NATURAL JOIN` becomes a cartesian (cross) join when no matching column names are found.
* `NATURAL JOIN` syntax:

  ```sql
  SELECT *
  FROM emp
  NATURAL JOIN dept
  ```
* Oracle join syntax:
    * INNER JOIN:

      ```sql
      SELECT *
      FROM emp, dept
      WHERE emp.deptno = dept.deptno
      ```
    * LEFT OUTER JOIN:

      ```sql
      SELECT *
      FROM emp, dept
      WHERE emp.deptno = dept.deptno (+)
      ```
    * RIGHT OUTER JOIN:

      ```sql
      SELECT *
      FROM emp, dept
      WHERE emp.deptno (+) = dept.deptno
      ```
* `USING` syntax

  ```sql
  SELECT *
  FROM emp
  JOIN dept USING(deptno)
  ```
* Queries with the `USING` syntax cannot alias the column(s) used in the `USING(...)` clause.

  ```sql
  SELECT d.deptno
  FROM emp e
  JOIN dept d USING(deptno)

  -- Results in ORA-25154: column part of USING clause cannot have qualifier.
  ```
* `USING`, `NATURAL JOIN` and `ON` are mutually exclusive and these JOIN types cannot be mixed.

# Using Subqueries to Solve Queries

## Subqueries
* Subqueries can be nested an unlimited depth in a `FROM`.
* Subqueries can "only" be nested 255 levels deep in a `WHERE`.
* Subqueries cannot be used in a `GROUP BY` or `ORDER BY`.

## Use a set operator to combine multiple queries into a single query
* `UNION`, `MINUS` and `INTERSECT` all remove duplicates and order the results. `UNION ALL` does neither of these.
* `ORDER BY` can only be used at the end of a compound (UNION, MINUS, INTERSECT) query and not in each individual part. If you put an `ORDER BY` for an individual query you will get `ORA-00933: SQL command not properly ended`.

# Managing Tables using DML statements

* Oracle is **ACID** compliant:
  * **A** tomicity: All or nothing.
  * **C** onsistency: Within a given statement the data manipulated is from the same starting point and not modified part way through.
  * **I** solated: Until committed, changed data cannot be seen by others.
  * **D** urable: Once committed the changes are never lost.
* If an error occurs during a statement the work of the statement is undone but the work of all other statements in the same transactions remain but uncommitted.
* Whilst sometimes categorized as DML, `TRUNCATE` is DDL and cannot be rolled back.

## Insert rows into a table
* The `VALUES` keyword is not used in an `INSERT ... AS SELECT ...` statement.

## Control transactions
* Transactions are started implicitly with DML.
* Transactions ended with `COMMIT` or `ROLLBACK`.
* `COMMIT` is fast, `ROLLBACK` is slow (can possibly take longer to ROLLBACK that it originally did to do the work).
* Create a `SAVEPOINT` with `SAVEPOINT name;`.
* `ROLLBACK` a `SAVEPOINT` with `ROLLBACK TO SAVEPOINT name;`.
* You cannot `ROLLBACK` to a non-existant `SAVEPOINT`. One that either has not been created or has been ended via a `ROLLBACK` or `COMMIT`.

# Introduction to Data Definition Language

* Object names...
  * must be no longer than 30 characters;
  * must start with a letter (A-Z);
  * must include only A-Z, 0-9, \_, $ or #.
  * must be upper case (even if entered lower case they will be converted to upper)''
  * may include additional characters and be lower case if enclosed with quotes ("). However, once this is done the object must always be referred to using quotes.
* Objects names are case sensitive.

  ```sql
  CREATE TABLE test1 (
    ...
  );

  CREATE TABLE "test1" (
    ...
  );

  -- Results in two tables, one called TEST1 and another called test1.
  ```
* Object names (schema.name) must be unique with their namespace.
* Indexes, constraints and procedures have their own namespace so they can share a name with tables, views, sequences and private synonyms even within the same schema. This is because you cannot reference these directly with a SELECT statement.
* DDL will fail if there is another active transaction against the object being altered.
* It is impossible to `DROP` a table if it is the subject of a `FOREIGN KEY` from another table.
* Oracle 12c includes a recycle bin that is enabled by default. Dropped objects can be recovered from here as long as they haven't been dropped with the `PURGE` option.
* You cannot `TRUNCATE` a table that has foreign key values pointing to it.

## Describe the data types that are available for columns
* The following datatypes are important to know for the exam:
  * `VARCHAR2` Variable-length character data from 1 byte to 4000 bytes if `MAX_STRING_SIZE=STANDARD` or 32767 bytes in `MAX_STRING_SIZE=EXTENDED`. The database is stored in the database character set.
  * `CHAR` Fixed-length character data, from 1 byte to 2000 bytes, in the database character set. If the data is not the length of the column then it will be padded with spaces.
  * `NUMBER` Numeric data, for which you can specify precision and scale. The precision can range from 1 to 38, the scale can range from -84 to 127.
  * `FLOAT` A subtype of the `NUMBER` datatype having a precision defined. A `FLOAT` value is represented internally as `NUMBER`. The precision can range from 1 to 126 binary digits. A `FLOAT` value requires from 1 to 22 bytes.
  * `DATE` The is either the length zero, if the column is empty or 7 bytes. All `DATE` data includes century, year, month, day, hour, minute and second.
  * `TIMESTAMP` This is length zero if the column is empty, or up to 11 bytes, depending on the precision specified. Similar to `DATE` but with precision of up to 9 decimal places for the seconds, 6 places by default.
  * `TIMESTAMP WITH TIMEZONE` Like `TIMESTAMP` but the data is stored with a record kept of the time zone to which it refers. The length may be up to 13 bytes, depending on precision. This data type lets Oracle determine the difference between two time by normalizing them to UTA, even if the times are for different time zones.
  * `TIMESTAMP WITH LOCAL TIMEZONE` Like `TIMESTAMP`, but the data is normalize to the database time zone on saving. When retrieved, it is normalized to the time zone of the user processing it.
  * `INTERVAL YEAR TO MONTH` Used for recording a period in years and months between two `DATE`s or `TIMESTAMP`s.
  * `INTERVAL DAY TO SECOND` Used for recording a period in days and seconds between two `DATE`s or `TIMESTAMP`s.
  * `RAW` Variable-length binary data, from 1 byte to 4000 bytes if `MAX_STRING_SIZE=STANDARD` or 32767 bytes if `MAX_STRING_SIZE=EXTENDED`. Unlike the `CHAR` and `VARCHAR2` data types, `RAW` data is not converted by Oracle Net from the databases character set to the user process's character set on `SELECT` or the other way on `INSERT`.
  * `LONG` Character data in the database character set, up to 2gb. All the functionality of `LONG` is provided by `CLOB`; `LONG`s should not be used in a modern database, and if your database has any columns of this type they should be converted to `CLOB`. There can only be one `LONG` column in a table.
  * `LONG RAW` Like `LONG`, but binary data that will not be converted by Oracle Net. Any `LONG RAW` columns should be converted to `BLOB`s.
  * `CLOB` Character data stored in the database character set, size effectively unlimited: (4gb - 1) multiplied by the database block size.
  * `BLOB` Like `CLOB` but binary data that will not undergo character set conversion by Oracle Net.
  * `BFILE` A locator pointing to a file stored on the operating system of the database server. The size of the files is limited to 4gb.
  * `ROWID` A value coded in base64 that is the pointer to the location of a row in a table. Encrypted within it is the exact physical address. `ROWID` is an Oracle proprietary data type, not visible unless specifically selected.
  * `BINARY_FLOAT` A 32-bit, single precision floating-point number. Each `BINARY_FLOAT` value requires 5 bytes, including a length byte.
  * `BINARY_DOUBLE` A 64-bit, double precision floating-point number datatype. Each `BINARY_DOUBLE` value requires 9 bytes, including a length byte.
* `VARCHAR2`, `NUMBER` and `DATE` required a detailed understanding.
* `NUMBER` with a negative scale will round:

  ```sql
  CREATE TABLE numtest (
    id NUMBER(12, -4)
  );

  INSERT INTO numtest VALUES (12);
  INSERT INTO numtest VALUES (12345);
  INSERT INTO numtest VALUES (56789);
  INSERT INTO numtest VALUES (99999);

  SELECT *
  FROM numtest;

  --          ID
  -- -----------
  --           0
  --       10000
  --       60000
  --      100000
  ```

## Create a simple table
* The syntax for columns in a `CREATE TABLE` statement is:

  ```sql
    column_name DATA_TYPE [NOT NULL] [UNIQUE | PRIMARY KEY]
  ```
* `CREATE TABLE ... AS SELECT ...` copies a tables structure including `NOT NULL` and `CHECK` constraints. `PRIMARY KEY`, `UNIQUE` and `FOREIGN KEY`s are not copied.
* Various `ALTER TABLE` options
  * Adding columns

    ```sql
    ALTER TABLE emp
    ADD (job_id NUMBER);
    ```
  * Modifying columns

    ```sql
    ALTER TABLE emp
    MODIFY (comm NUMBER(4,2) DEFAULT 0.05);
    ```
  * Dropping columns

    ```sql
    ALTER TABLE emp
    DROP COLUMN comm;
    ```
  * Marking columns as unused

    ```sql
    ALTER TABLE emp
    SET UNUSED COLUMN job_id;
    ```
  * Renaming columns

    ```sql
    ALTER TABLE emp
    RENAME COLUMN hiredate TO recruited
    ```
  * Marking the table as read-only

    ```sql
    ALTER TABLE emp
    READ ONLY;
    ```

## Explain how constraints are created at the time of table creation
* `UNIQUE` constraints ignore `NULL` values.
* `PRIMARY KEY` is a combination of `UNIQUE` and `NOT NULL`.
* `FOREING KEY` constraints must reference columns of a `UNIQUE` or `PRIMARY KEY` constraint in the referenced table.
* `DELETE`ing rows in a `FOREIGN KEY` referenced table is not allowed unless the constraint is specified with one of the following:
  * `ON DELETE CASCADE` Also delete the rows referencing the row to be deleted.
  * `ON DELETE SET NULL` Find any rows referencing the row to be deleted and make `NULL` the columns in the `FOREIGN KEY`.


# Exams Gotchas

The following notes are not strictly Oracle Database related but should be remembered when taking the exam.

* When provided with details of two or more tables (such as via a `DESC`) be sure to examine the column names carefully and check for any columns in both tables with the same name, especially if a `NATURAL JOIN` is used anywhere in the questions. Be 100% certain of the columns the `NATURAL JOIN` will be operating on.
* When dealing with data conversions be sure to consider the `NLS_DATE_FORMAT` setting and whether the question relies on this or has possibly changed it.
* Ensure that the datatypes are correct in functions. For example, the data types of all arguments to `COALESCE` must be the same. Do not rely on implicit casting with `COALESCE` either.