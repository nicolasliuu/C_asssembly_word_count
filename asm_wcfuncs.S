/*
 * Assembly language function implementations
 */

#define MAX_WORDLEN 63

/*
 * Offsets for the fields of the struct WordEntry data type
 * (Note that there is 4 bytes of padding between the count and next
 * fields.)
 */
#define WORDENTRY_WORD_OFFSET   (0)
#define WORDENTRY_COUNT_OFFSET  (MAX_WORDLEN+1)
#define WORDENTRY_NEXT_OFFSET   (MAX_WORDLEN+1+4+4)
#define WORDENTRY_SIZE (WORDENTRY_NEXT_OFFSET+8)

	.section .rodata
/* Define any string constants or read-only data here */

	.section .text

/*
 * Compute a hash code for the given NUL-terminated
 * character string.
 *
 * The hash algorithm should be implemented as follows:
 *
 * uint32_t hash_code = 5381
 * for each character c of w in order {
 *   hash_code = hash_code * 33 + c
 * }
 *
 * Note that the character values should be treated as
 * being unsigned (in the range 0..255)
 *
 * C function prototype:
 *    uint32_t wc_hash(const unsigned char *w);
 */
	.globl wc_hash
wc_hash:
	subq $8, %rsp      /* adjust stack pointer */
	movl $5381, %r11d /* initialize hash_code to 5381 */

.LhashLoop: 
	cmpb $0, (%rdi) /* check if at end of string */
	je .LhashDone
	imull $33, %r11d /* hash_code = hash_code * 33 */
	movzbl (%rdi), %eax /* move character into %eax */
	addl %eax, %r11d /* hash_code = hash_code + c */
	incq %rdi /* increment pointer */
	jmp .LhashLoop

.LhashDone:
	movl %r11d, %eax /* return hash_code */
	addq $8, %rsp      /* restore stack pointer */
	ret

/*
 * Compare two strings lexicographically. Return
 *
 * - a negative value if lhs string is less than rhs string
 * - 0 if lhs string is identical to rhs string
 * - a positive value if lhs string is greater than rhs string
 *
 * Lexicographical comparison is a generalization of alphabetical
 * order, but using character codes. If one string is a prefix
 * of the other, it is considered as "less than". E.g.,
 * "hi" would compare as less than "high".
 *
 * C function prototype:
 *    int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs);
 */
	.globl wc_str_compare
wc_str_compare:
	/* First store the pointers to lhs string and rhs string in two different registers, like r10 and r11 */
	movb (%rdi), %r10b /* *lhs */
	movb (%rsi), %r11b /* *rhs */

	/* Enter loop */
	.LstrCmpLoop:
		cmpb %r10b, %r11b /* compare lhs and rhs character (loop condition)*/
		jne .Lnotequal /* if no jump, enter loop body */
		/*jl .Lless
		jg .Lgreater*/
		cmpb $0, %r10b /* at end of string? */
		je .Lequal /* if at end of string, exit loop */
		inc %rdi /* lhs++ */
		inc %rsi /* rhs++ */
		movb (%rdi), %r10b /* update r10 to be character pointed to by rdi*/
		movb (%rsi), %r11b /* update r11 to be character pointed to by rsi */
		jmp .LstrCmpLoop

	.Lequal: /*return 0*/
		movl $0, %eax
		ret

	.Lless: /* return -1 */
		movl $-1, %eax
		ret


	.Lgreater: /* return 1 */
		movl $1, %eax
		ret


	.Lnotequal: /*return difference between lhs and rhs*/
		/*subb %r11b, %r10b
		movq %r11, %rax*/
		cmpb $0, %r10b /* lhs shorter than rhs */
		je .Lless
		cmpb $0, %r11b /* rhs shorter than lhs */
		je .Lgreater
		cmpb %r11b, %r10b
		jl .Lless /* lhs less than rhs */
		cmpb %r11b, %r10b
		jg .Lgreater /* lhs greater than rhs */

		ret


/*
 * Copy NUL-terminated source string to the destination buffer.
 *
 * C function prototype:
 *    void wc_str_copy(unsigned char *dest, const unsigned char *source);
 */
	.globl wc_str_copy
wc_str_copy:
	.LcopyLoop:
		movb (%rsi), %r11b /* source */
		cmp $0, %r11b /*check if at end of source*/
		je .Lend /* end loop if at end of source */
		movb %r11b, (%rdi) /* put current character of source into destination */
		inc %rdi /* dest++ */
		inc %rsi /* source++ */
		jmp .LcopyLoop

	.Lend:
		ret

/*
 * Return 1 if the character code in c is a whitespace character,
 * false otherwise.
 *
 * For the purposes of this function, a whitespace character is one of
 *
 *   ' ' 32
 *   '\t' 9
 *   '\r' 13
 *   '\n' 10
 *   '\f' 12
 *   '\v' 11
 *
 * C function prototype:
 *    int wc_isspace(unsigned char c);
 */
	.globl wc_isspace
wc_isspace:
	mov %dil, %al

	cmpb $9, %al  /* \t */
	je .Lisspace

	cmpb $10, %al /* \n */
	je .Lisspace

	cmpb $11, %al /* \v */
	je .Lisspace

	cmpb $12, %al /* \f */
	je .Lisspace

	cmpb $13, %al /* \r */
	je .Lisspace

	cmpb $32, %al /* space */
	je .Lisspace

	.Lnotspace:
		movq $0, %rax/*return 0 if not space*/
		ret

	.Lisspace:
		movq $1, %rax/*return 1 if space*/
		ret

	ret

/*
 * Return 1 if the character code in c is an alphabetic character
 * ('A' through 'Z' or 'a' through 'z'), 0 otherwise.
 *
 * C function prototype:
 *    int wc_isalpha(unsigned char c);
 */
	.globl wc_isalpha
wc_isalpha:
	/* First argument is stored in the lowest register of %rdi, load it into lowest regiter of %r10*/
	movq %rdi, %r10

	/* Check if the character is in the range of 'A' to 'Z' */
	cmp $65, %r10
	jl .Lnot_alpha
	/* The character is greater than A and less than Z, so it is alphabetic*/
	cmp $90, %r10
	jle .Lis_alpha

	/* Check if the character is in the range of 'a' to 'z' */
	cmp $97, %r10
	jl .Lnot_alpha	
	/* The character is greater than a and less than z, so it is alphabetic*/
	cmp $122, %r10
	jle .Lis_alpha
	jge .Lnot_alpha /* character is not alpha if greater than ASCII 122 */

	.Lis_alpha:
		# Move 1 to the return register and return
		movq $1, %rax
		ret

	.Lnot_alpha:
		# Move 0 to the return register and return
		movq $0, %rax
		ret

/*
 * Read the next word from given input stream, storing
 * the word in the array pointed-to by w. (This array should be
 * assumed to be MAX_WORDLEN+1 elements in size.) Return 1
 * if a word is read successfully, 0 otherwise.
 *
 * For the purposes of this function, a word is a sequence of
 * 1 or more non-whitespace characters.
 *
 * If a sequence of non-whitespace characters has more than
 * MAX_WORDLEN characters, then only the first MAX_WORDLEN
 * characters in the sequence should be stored in the array.
 *
 * C function prototype:
 *    int wc_readnext(FILE *in, unsigned char *w);
 */
	.globl wc_readnext
wc_readnext:
	# File pointer in %rdi and pointer to character string w in %rsi
	subq $8, %rsp      /* adjust stack pointer */
	movq %rdi, %r10    /* save file pointer in %r10 */
	movq %rsi, %r11    /* save pointer to character string w in %r11 */
	movq $0, %r12 		/* Counter */

.Lread_clearwhite:
	# Clear whitespace characters
	movq %r10, %rdi
	call fgetc 
	cmpq $-1, %rax
	je .LreadFail
	
	# Call fgetc to get the next character and call wc_isspace to check if it is whitespace
	
	movq %rax, %rdi
	call wc_isspace
	cmpq $1, %rax
	je .Lread_clearwhite
	# We have a non-whitespace character, so we can start reading the word

.LreadLoop: 
	# Stop at the next whitespace character, EOF, or MAX_WORDLEN characters
	cmpq $-1, %rdi
	je .LreadDone
	cmpq $MAX_WORDLEN, %r12
	je .LreadDone
	# Keep character in rax to call wc_isspace
	call wc_isspace
	cmpq $1, %rax
	je .LreadDone
	# We have a non-whitespace character, so we can start reading the word
	movb %dil, (%r11)
	inc %r12 # increment counter
	inc %r11 # increment pointer w character string
	movq %r10, %rdi
	call fgetc
	jmp .LreadLoop

.LreadDone:
	movb $0, (%r11) # set last character to NUL
	cmpq $0, %r12
	je .LreadFail
	movq $1, %rax
	addq $8, %rsp      /* restore stack pointer */
	ret

.LreadFail:
	movq $0, %rax
	addq $8, %rsp      /* restore stack pointer */
	ret

/*
 * Convert the NUL-terminated character string in the array
 * pointed-to by w so that every letter is lower-case.
 *
 * C function prototype:
 *    void wc_tolower(unsigned char *w);
 */
	.globl wc_tolower
wc_tolower:
	/* TODO: implement */
	subq $8, %rsp      /* adjust stack pointer */
	movq %rdi, %r10    /* save pointer to character string w */
	
.LtoLowerLoop:
	cmpb $0, (%r10)    /* check if at end of string */
	je .LtoLowerDone	/* if at end of string, exit loop */

.LisUpper: 	
	/* Call wc_isalpha to check if currrent character is alphabetic */
	/*  call wc_isalpha */

	cmpb $65, (%r10) /* check if character is upper case */
	jl .LtoLowerInc /* if character is lower case, increment pointer */
	cmpb $90, (%r10)
	jg .LtoLowerInc /* if character is lower case, increment pointer */

	/* character is upper case, convert to lower case */
	addb $32, (%r10) /* add 32 to convert to lower case */
	jmp .LtoLowerInc

.LtoLowerInc:
	inc %r10 /* increment pointer */
	jmp .LtoLowerLoop

.LtoLowerDone:
	/* just return */
	addq $8, %rsp      /* restore stack pointer */
	ret

/*
 * Remove any non-alphaabetic characters from the end of the
 * NUL-terminated character string pointed-to by w.
 *
 * C function prototype:
 *    void wc_trim_non_alpha(unsigned char *w);
 */
	.globl wc_trim_non_alpha
wc_trim_non_alpha:
	subq $8, %rsp 	/* adjust stack pointer */
	movq %rdi, %r10 /* copy pointer to character string w into %r10 */
	
.LfindEnd: 
	# Loop to reach the end of the NUL-terminated character string pointed-to by w
	cmpq $0, (%r10) /* check if at end of string */
	je .LtrimLoop	/* if at end of string, exit loop */
	inc %r10 /* increment pointer */
	jmp .LfindEnd

.LtrimLoop:
	# We reached the end of the string, now we need to trim the non-alpha characters
	dec %r10 /* decrement pointer */
	# Make a call to wc_isalpha to check if the current character is alphabetic
	pushq %r10 /* Save $r10 before calling wc_isalpha */
	movq (%r10), %rdi /* move pointer to character string w into %rdi */
	call wc_isalpha
	popq %r10 /* pop pointer to character string w off of stack */
	cmpq $1, %rax /* check if character is alphabetic */
	je .LtrimDone /* if character is alphabetic, exit loop */
	# Trim this character
	movb $0, (%r10) /* set character to NUL */
	jmp .LtrimLoop

.LtrimDone: 
	addq $8, %rsp      /* restore stack pointer */
	ret

/*
 * Search the specified linked list of WordEntry objects for an object
 * containing the specified string.
 *
 * If a matching object is found, set the int variable pointed-to by
 * inserted to 0 and return a pointer to the matching object.
 *
 * If a matching object is not found, allocate a new WordEntry object,
 * set its next pointer to point to what head points to (i.e., so the
 * new object is at the head of the list), set the variable pointed-to
 * by inserted to 1, and return a pointer to the new node. Note that
 * the new node should have its count value set to 0. (It is the caller's
 * job to update the count.)
 *
 * C function prototype:
 *    struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s, int *inserted);
 */
	.globl wc_find_or_insert
wc_find_or_insert:
	/*
	rdi = head
	rsi = s
	rdx = inserted
	*/
	subq $8, %rsp 
	movq %rdi, %r13 # cursor = head
	movq %rsi, %r12
	.LfindWordLoop:
		cmp $0, %r13 # while cursor != null
		jz .LnotFound
		movq %r13, %rdi
		call wc_str_compare # compare cursor's word (rdi) with s (rsi)
		cmp $0, %rax # if str compare == 0
		je .LfoundWord
		inc %r13 # cursor = cursor->next
		jmp .LfindWordLoop

	.LnotFound:
		mov $WORDENTRY_SIZE, %rdi # allocating size of word entry
		call malloc # malloc new node
		movq %r12, %rsi
		movq %rax, %r11 # r11 contains new node
		mov WORDENTRY_WORD_OFFSET(%r11), %rdi # getting the word at new node and putting it into rdi
		# str copy segfaulting, problem with rdi??
		call wc_str_copy # wc_str_copy(new_node->word, s) copy s into new_node->word
		movq %rdi, WORDENTRY_WORD_OFFSET(%r11)
		movq %rdi, WORDENTRY_NEXT_OFFSET(%r11) # next = head
		movq %r11, %rdi # head = new_node
		movl $1, (%rdx) # inserted = 1
		movq $0, WORDENTRY_COUNT_OFFSET(%r11) # setting new_node->count to 0
		movq %r11, %rax
		addq $8, %rsp 
		ret

	.LfoundWord:
		movq $0, %rdx
		movq %r13, %rax
		addq $8, %rsp 
		ret



/*
 * Find or insert the WordEntry object for the given string (s), returning
 * a pointer to it. The head of the linked list which contains (or should
 * contain) the entry for s is the element of buckets whose index is the
 * hash code of s mod num_buckets.
 *
 * Returns a pointer to the WordEntry object in the appropriate linked list
 * which represents s.
 *
 * C function prototype:
 *    struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[], unsigned num_buckets, const unsigned char *s);
 */
	.globl wc_dict_find_or_insert
wc_dict_find_or_insert:
	/* TODO: implement */
	movq %r10, %rdi
	call wc_hash
	movq %rax, %r10 # put hash value in r10

	ret

/*
 * Free all of the nodes in given linked list of WordEntry objects.
 *
 * C function prototype:
 *    void wc_free_chain(struct WordEntry *p);
 */
	.globl wc_free_chain
wc_free_chain:
	/* TODO: implement */
	ret

/*
vim:ft=gas:
*/
