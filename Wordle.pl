main:-	
	write("Welcome to Pro-Wordle!"),
	nl,
	build_kb,
	nl,
	play.
	
build_kb:-
	write("Please enter a word and its category on separate lines:"),
	nl,
	read(W),
	(
		(W = done , nl, write("Done building the words database..."),nl);
		read(C),
		assert(word(W,C)),
		build_kb
	).
	

play:-
	write("The available categories are: "),
	categories(C1),
	write(C1),
	nl,
	cat_help(C),
	len_help(L,C),
	Len = L,
	G is Len+1,
	nl,
	write("Game started. You have "),
	write(G),
	write(" guesses."),
	nl,
	write("Enter a word composed of "),
	write(L),
	write(" letters:"),
	nl,
	read(W),
	nl,
	pick_random(Word,L,C),
	engine(Word,L,C,G,W).
	
cat_help(C):-
		write("Choose a category:"),
		nl,
		cat_helperAvail(C).
	
cat_helperAvail(X):-
	read(X1),
	(	
		(is_category(X1),X=X1);
		\+is_category(X1),
		write("This category does not exist."),
		nl,
		write("Choose a category:"),
		nl,
		cat_helperAvail(X2)
	).

		
len_help(L,C):-
	write("Choose a length:"),
	nl,
	read(X),
	(
	(available_length(X,C),L=X);
	\+available_length(X,C),
	write("There are no words of this length."),
	nl,
	len_help(L,C)
	).


engine(Word,L,C,G,W):-
	(
		G>0,
		Word=W,
		write("You Won!"),!
	);

	( lost_predicate(G,Word,W),! );
	string_length(W,Len),
	(
		Len\==L,
		notSameLength_Predicate(Word,L,G,C)
	);
	
	(
	atom_chars(Word,L1),
	atom_chars(W,L2),
	correct_letters(L1,L2,CL),
	correct_positions(L1,L2,CP),
 	write("Correct letters are: "),
	write(CL),
	nl,
	write("Correct letters in correct positions are: "),
	write(CP),
	nl,
	G1 is G-1,
	write("Remaining Guesses are "),
	write(G1),
	nl,
	write("Enter a word composed of "),
	write(L),
	write(" letters:"),
	nl,
	read(W2),
	engine(Word,L,C,G1,W2),!
	).

lost_predicate(G,W,Word):-
		G=1,
		Word\==W,
		write("You Lost!").

notSameLength_Predicate(Word,L,G,C):-	
		write("Word is not composed of "),
		write(L),
		write(" letters. Try again."),
		nl,
		write("Remaining Guesses are "),
		write(G),
		nl,
		write("Enter a word composed of "),
		write(L),
		write(" letters:"),
		nl,
		read(W1),
		engine(Word,L,C,G,W1),!.


is_category(C):-
	word(_,C).
	
	
categories(L):-
	setof(C,is_category(C),L).


available_length(L):-
	bagof(W,word(W,_),L1),
	helper(L,L1).
	
available_length(L,C):-
	bagof(W,word(W,C),L1),
	helper(L,L1).

helper(L,[H|T]):-
(
	string_length(H,S),
	L\==S,
	helper(L,T)
);
	string_length(H,L),!.

	
pick_word(W,L,C):-
	word(W,C),
	string_length(W,L).

	
pick_random(W,L,C):-
	setof(W1,pick_word(W1,L,C),List),
	choose(List,W).

	
choose([],[]).
choose(List,Elt):-
	length(List,Length),
	random(0,Length,Index),
	nth0(Index,List,Elt).
	
	
correct_letters([],_,[]).
correct_letters([H|T],Y,[H|R]):-
	member(H,Y),
	correct_letters(T,Y,R).
correct_letters([H|T],Y,R):-
	\+member(H,Y),
	correct_letters(T,Y,R).	
	
		
correct_positions([],[],[]).
correct_positions([_],[],[]).
correct_positions([],[_],[]).
correct_positions([H1|T1],[H2|T2],L):-
	H1==H2,
	correct_positions(T1,T2,L3),
	append([H1],L3,L).

correct_positions([H1|T1],[H2|T2],T):-
	H1\==H2,
	correct_positions(T1,T2,T).