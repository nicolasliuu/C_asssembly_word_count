// Important: do not add any additional #include directives!
// The only C library functions that may be used are
//
// - fgetc
// - malloc
// - free

#include <stdlib.h>
#include "wcfuncs.h"

// Compute a hash code for the given NUL-terminated
// character string.
//
// The hash algorithm should be implemented as follows:
//
// uint32_t hash_code = 5381
// for each character c of w in order {
//   hash_code = hash_code * 33 + c
// }
//
// Note that the character values should be treated as
// being unsigned (in the range 0..255)
uint32_t wc_hash(const unsigned char *w) {
  uint32_t hash_code = 5381;
  // for (int i = 0; w[i] != '\0'; i++) {
  //   hash_code = hash_code * 33 + w[i];
  // }

  while (*w != '\0') {
    hash_code = hash_code * 33 + *w;
    w++;
  }

  return hash_code;
}

// Compare two strings lexicographically. Return
//
// - a negative value if lhs string is less than rhs string
// - 0 if lhs string is identical to rhs string
// - a positive value if lhs string is greater than rhs string
//
// Lexicographical comparison is a generalization of alphabetical
// order, but using character codes. If one string is a prefix
// of the other, it is considered as "less than". E.g.,
// "hi" would compare as less than "high".
int wc_str_compare(const unsigned char *lhs, const unsigned char *rhs) {  
  while ((*lhs != '\0' || *rhs != '\0')){
    if (*lhs == *rhs) {
      lhs++;
      rhs++;
    } else if ((*lhs == '\0' && *rhs != '\0') || (*lhs != '\0' && *rhs == '\0') || (*lhs != *rhs)) {
      return *lhs - *rhs;
    } 

  }
  return 0;
  //loop thru each string as long as pointer not at the end
    //if lhs char == rhs char, increment both
    //else add up sum of all characters in lhs and all characters in rhs and compute difference
      //return difference
  //return 0
}

// Copy NUL-terminated source string to the destination buffer.
void wc_str_copy(unsigned char *dest, const unsigned char *source) {
  // TODO: implement
  while (*source != '\0') {
    *dest = *source;
    dest++;
    source++;
  }
}

// Return 1 if the character code in c is a whitespace character,
// false otherwise.
//
// For the purposes of this function, a whitespace character is one of
//
//   ' '
//   '\t'
//   '\r'
//   '\n'
//   '\f'
//   '\v'
int wc_isspace(unsigned char c) {
  // TODO: implement
  if (c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == '\f' || c == '\v') {
    return 1;
  }
  return 0;
}

// Return 1 if the character code in c is an alphabetic character
// ('A' through 'Z' or 'a' through 'z'), 0 otherwise.
int wc_isalpha(unsigned char c) {
  if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) {
    return 1;
  }
  return 0;
}

// Read the next word from given input stream, storing
// the word in the array pointed-to by w. (This array should be
// assumed to be MAX_WORDLEN+1 elements in size.) Return 1
// if a word is read successfully, 0 otherwise.
//
// For the purposes of this function, a word is a sequence of
// 1 or more non-whitespace characters.
//
// If a sequence of non-whitespace characters has more than
// MAX_WORDLEN characters, then only the first MAX_WORDLEN
// characters in the sequence should be stored in the array.
int wc_readnext(FILE *in, unsigned char *w) {

  // Assume w points to an array of MAX_WORDLEN+1 elements

  if (in == NULL || w == NULL) {
    return 0;
  }

  int pos = 0;
  int current_char = fgetc(in);

  while (wc_isspace(current_char)) {
    current_char = fgetc(in);
  }

  if (current_char == EOF) {
    return 0;
  }

  // While current character in in is not a whitespace or EOF
  while (!wc_isspace(current_char) && current_char != EOF && pos < MAX_WORDLEN) {
    // Add current character to w
    w[pos] = (unsigned char) current_char;
    pos++;
    current_char = fgetc(in); // Get next character
  }

  // Add a null terminator when the loop ends
  w[pos] = '\0';

  // Return 0 if pos is 0 (no word was read)
  if (pos == 0) {
    return 0;
  }

  return 1;
}

// Convert the NUL-terminated character string in the array
// pointed-to by w so that every letter is lower-case.
void wc_tolower(unsigned char *w) {
  // Loop through the array and if the char is uppercase, add 32 to it
  while (*w != '\0') {
    if (*w >= 65 && *w <= 90) {
      *w += 32;
    }
    w++;
  }
}

// Remove any non-alphaabetic characters from the end of the
// NUL-terminated character string pointed-to by w.
void wc_trim_non_alpha(unsigned char *w) {
  // Start at the end of the character string and go backwards
  int pos = 0;
  while (w[pos] != '\0') {
    pos++;
  }
  pos--; // pos is now the index of the last character in the string
  while (pos >= 0 && !(wc_isalpha(w[pos]))) {
    w[pos] = '\0';
    pos--;
  }
}

// Search the specified linked list of WordEntry objects for an object
// containing the specified string.
//
// If a matching object is found, set the int variable pointed-to by
// inserted to 0 and return a pointer to the matching object.
//
// If a matching object is not found, allocate a new WordEntry object,
// set its next pointer to point to what head points to (i.e., so the
// new object is at the head of the list), set the variable pointed-to
// by inserted to 1, and return a pointer to the new node. Note that
// the new node should have its count value set to 0. (It is the caller's
// job to update the count.)
struct WordEntry *wc_find_or_insert(struct WordEntry *head, const unsigned char *s, int *inserted) {
  // TODO: implement
  // Start at head, linear search through linkedlist until match is found
    // If match is found, set inserted to 0, return pointer to matching object
    if (head == NULL) {
      head = malloc(sizeof(struct WordEntry));
      // No garbage in head->word
      for (int i = 0; i < MAX_WORDLEN + 1; i++) {
        head->word[i] = '\0';
      }

      wc_str_copy(head->word, s);
      head->count = 0;
      head->next = NULL;
      *inserted = 1;
      return head;
    }
    struct WordEntry *cursor = head;
    // printf("%s %s %d\n", cursor->word, s, wc_str_compare(cursor->word, s));
    //find the word
    while (cursor != NULL) {
      if (wc_str_compare(cursor->word, s) == 0) {
        *inserted = 0;
        return cursor;
      } else {
        cursor = cursor->next;
      }
    }
    // If not found, create new WordEntry object, set next to head, set inserted to 1, return pointer to new node
    // struct WordEntry *temp = head->next; //first word in LL // THIS DONT DO ANYTHING?
    struct WordEntry *new_node = malloc(sizeof(struct WordEntry));
      for (int i = 0; i < MAX_WORDLEN + 1; i++) {
        new_node->word[i] = '\0';
      }
    // new_node->next = temp;//make new node first in LLfa
    new_node->next = head;
    head = new_node; //make dummy node point to new node
    //temp = head.next
    //head.next = new node
    //new node.next = temp
    // printf("'%s'\n", s);
    // Make sure new_node->word doesn't have garbage in it
    // for (int i = 0; i < MAX_WORDLEN + 1; i++) {
    //   new_node->word[i] = '\0';
    // }

    wc_str_copy(new_node->word, s); 
    // new_node->next = head;
    // cursor->next = new_node;
    // printf("%s %d\n",cursor->next->word, *inserted);
    *inserted = 1;
    // printf("%d\n", *inserted);
    // cursor->next->count = 0;
    new_node->count = 0;
    return new_node;
}

// Find or insert the WordEntry object for the given string (s), returning
// a pointer to it. The head of the linked list which contains (or should
// contain) the entry for s is the element of buckets whose index is the
// hash code of s mod num_buckets.
//
// Returns a pointer to the WordEntry object in the appropriate linked list
// which represents s.
struct WordEntry *wc_dict_find_or_insert(struct WordEntry *buckets[], unsigned num_buckets, const unsigned char *s) {
  // Hash the string s
  uint32_t hash_code = wc_hash(s);
  // Find the index of the bucket
  int index = hash_code % num_buckets;

  // Find or insert the WordEntry object for the given string (s), returning a pointer to it.
  int inserted = 0;
  struct WordEntry *entry = wc_find_or_insert(buckets[index], s, &inserted);
  if (inserted == 1) {
    buckets[index] = entry;
  }
  return entry;
}

// Free all of the nodes in given linked list of WordEntry objects.
void wc_free_chain(struct WordEntry *p) {
  struct WordEntry *temp = p;
  while (p != NULL) {
    temp = p->next;
    free(p);
    p = temp;
  }
}
