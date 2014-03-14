#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "newrelic_common.h"
#include "newrelic_transaction.h"

#include "perl_newrelic.h"

#include "const-c.inc"

MODULE = Net::NewRelic		PACKAGE = Net::NewRelic		

INCLUDE: const-xs.inc

long
newrelic_transaction_begin()

int
newrelic_transaction_end(tid)
    long tid
    
int
newrelic_transaction_set_name(transaction_id, name)
        long    transaction_id
        char   *name

int
newrelic_transaction_set_request_url(transaction_id, request_url)
        long    transaction_id
        char   *request_url    

long
newrelic_segment_generic_begin(transaction_id, parent_segment_id, name)
        long    transaction_id
        long    parent_segment_id
        char   *name

int
newrelic_segment_end(transaction_id, segment_id)
        long    transaction_id
        long    segment_id

int
newrelic_transaction_add_attribute(transaction_id, name, value)
        long    transaction_id
        char    *name
        char    *value                  

int
newrelic_transaction_notice_error(transaction_id, exception_type, error_message, stack_trace, stack_frame_delimiter)
        long    transaction_id
        char    *exception_type
        char    *error_message
        char    *stack_trace
        char    *stack_frame_delimiter

long
newrelic_segment_datastore_begin(transaction_id, parent_segment_id, table, operation)
        long    transaction_id
        long    parent_segment_id
        char    *table
        char    *operation

int
newrelic_transaction_set_max_trace_segments(transaction_id, max_trace_segments)
        long    transaction_id
        int     max_trace_segments

int
newrelic_transaction_set_threshold(transaction_id, threshold)
        long    transaction_id
        int     threshold
