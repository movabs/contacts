#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

our $loop = 1;

sub getContacts {
    open FILE, 'contacts.txt';
    chomp (my @content = <FILE>);
    close FILE;
    my @contacts = sort (@content);
    my $i = 1;

    printf("############################## Contacts ##############################\n");
    foreach (@contacts) {
        my @info = split /-/, $_;
        printf "$i. $info[0] $info[1], number: @info[2], email: @info[3]\n";
        $i++;
    }
    printf("######################################################################\n");
}

sub getName {
    chomp (my $name = <STDIN>);
    until ($name =~ /\A[a-zA-Z]/) {
        printf "Invalid name, chose a valid name please!\n";
        chomp ($name = <STDIN>);
    }
    return($name);
}

sub getEmail {
    printf "Email: ";
    chomp (my $email = <STDIN>);
    until ($email =~ /\A.+@.+\..+/) {
        printf "Invalid email, please type a valid email\n";
        chomp ($email = <STDIN>);
    }
    return($email);
}

# TODO: make sure the contact doesnt exist
sub addContact {
    printf "Firstname: ";
    my $name = getName;
    printf "Lastname: ";
    my $lastname = getName;
    printf "Number: ";
    chomp (my $number = <STDIN>);
    my $email = getEmail;
    my $contact = "$name\-$lastname\-$number\-$email";
    open FILE, '>>contacts.txt';
    print FILE "$contact\n";
    close FILE;
    printf "Contact has been added!\n";
}

sub searchContacts{
    open FILE, "contacts.txt";
    chomp (my @contacts = <FILE>);
    close FILE;
    my $searchTerm;
    my $searchChecker = -1;

    if($_[0]) {
        print "Enter the EXACT NAME of your desired contact: ";
        chomp ($searchTerm = <STDIN>);

        foreach (@contacts){
            if ($_ =~ /\A($searchTerm)-/i){
                my @info = split /-/, $_;
                say "\n$info[0] - $info[1] - $info[2] - $info[3]";
                return ($_, $info[0]);
            }else{
                $searchChecker ++;
            }
        }
    } else {
        print "Search your contacts by name: ";
        chomp ($searchTerm = <STDIN>);
        print "\n";

        my $i = 1;
        foreach (@contacts){
            if ($_ =~ /\A$searchTerm/i){
                my @info = split /-/, $_;
                say "$i. $info[0] - $info[1] - $info[2] - $info[3]";
                $i++;
            }else{
                $searchChecker ++;
            }
        }
    }

    if ($searchChecker == $#contacts){
        printf("Contact not found\n");
        return('null');
    }
}

sub removeContact{
    my $unwantedTerm;
    my $name;
    my $deleteChoice;

    if ($_[0]) {
        $unwantedTerm = $_[0];
        $deleteChoice = 'y';
    } else {
        ($unwantedTerm, $name) = searchContacts(1);
        return() if $unwantedTerm eq 'null';

        print "\nAre you sure you want to delete \"$name\"? [y/n]: ";
        chomp ($deleteChoice = <STDIN>);
    }
    if ($deleteChoice =~ /\Ay/i){
        open FILE, "<contacts.txt";
        my @file = <FILE>;
        close (FILE);
        open (FILE, ">contacts.txt");
        foreach my $line (@file){
            print FILE $line unless ($line =~ /$unwantedTerm/);
        }
        close (FILE);

        printf("\n$name deleted\n") unless ($_[0]);
    } else {
        say "\nDeletion canceled\n";
        return();
    }
}

sub editContact {
    my ($desired_line, $name) = searchContacts(1);
    return() if $desired_line eq 'null';

    my @info = split /-/, $desired_line;

    say "Would you like edit the Firstname(1), LastName(2), Number(3), or email(4)?";
    print "Enter your choice: ";
    chomp (my $choice = <STDIN>);

    until ($choice =~ /[1-4]/){
        printf("Invalid choice, please make a valid choice:\n");
        say "Would you like edit the Firstname(1), LastName(2), Number(3), or email(4)?";
        print "Enter your choice: ";
        chomp ($choice = <STDIN>);
    }

    if ($choice == 1) {
        printf("Enter new firstname: ");
        $info[0] = getName;
    } elsif ($choice == 2) {
        printf "Enter new lastname: ";
        $info[1] = getName;
    } elsif ($choice == 3) {
        printf "Enter new number: ";
        chomp ($info[2] = <STDIN>);
    } elsif ($choice == 4) {
        printf("Enter new email\n");
        $info[3] = getEmail;
    }

    removeContact($desired_line);

    my $newContact = "$info[0]\-$info[1]\-$info[2]\-$info[3]";
    open FILE, ">>contacts.txt";
    print FILE "$newContact\n";
    close FILE;
    printf("Contact updated\n");
}

printf "### Contact book APP ###\n";

# The main loop of the program
while ($loop == 1) {
    printf "Menu:\n";
    printf "1. Add a new contact\n";
    printf "2. Show contacts\n";
    printf "3. Edit a contact\n";
    printf "4. Delete a contact\n";
    printf "5. Search a contact\n";
    printf "0. Quit the program\n";

    chomp (my $input = <STDIN>);

    until ($input =~ /[0-5]/) {
        printf "Bad choice\n";
        chomp ($input = <STDIN>);
    }

    if ($input == 1) {
        addContact;
    } elsif ($input == 2) {
        getContacts;
    } elsif ($input == 3) {
        editContact;
    } elsif ($input == 4) {
        removeContact;
    } elsif ($input == 5) {
        searchContacts;
    } else {
        $loop = 0;
    }
}