--------------------------------------------------------------------------------
-- Trace sql net
--------------------------------------------------------------------------------

Add the following parameters in the sqlnet.ora file on the CLIENT workstation:

TRACE_LEVEL_CLIENT=16
TRACE_DIRECTORY_CLIENT=<some_known_directory>
TRACE_UNIQUE_CLIENT=ON
DIAG_ADR_ENABLED =OFF         

If you need to restrict the amount of disk space used by only the long-term traces then you can also set the following:

TRACE_FILELEN_CLIENT=<file_size_in_Kbytes>
TRACE_FILENO_CLIENT=<number_of_files>