package BuildOpenSSL;

use warnings;
use strict;

use File::Path qw[rmtree];

my $launchVisualStudioEnv = '"C:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat"';

sub doSystemCommand
{
    my $systemCommand = $_[0];
    my $returnCode = system ($systemCommand);
    if ($returnCode != 0) 
    { 
        die ("Failed executing [$systemCommand]\n"); 
    }
}

sub clean
{
	my ($dir) = @_;
	print ("\nCleaning directory $dir\n");

	rmtree ($dir);
}

sub clone
{
	my ($path) = @_;
	print ("\nCloning OpenSSL\n");
	
	doSystemCommand ("git clone https://github.com/openssl/openssl.git $path");
	chdir ("openssl");
	doSystemCommand ("git fetch");
	doSystemCommand ("git checkout -b 1.0.2 origin/OpenSSL_1_0_2-stable");
	chdir ("..");
}

sub build
{
	my ($path) = shift;
	my ($arch) = shift;
	print ("\nBuilding OpenSSL\n");

	my %platform_dependent = (
		'arch_str' => {32 => 'x86', 64 => 'amd64'},
		'configure_arg' => { 32 => 'VC-WIN32', 64 => 'VC-WIN64A' },
		'do_ms' => {32 => 'ms\\do_ms', 64 => 'ms\\do_win64a'},
	);

	chdir ($path);
	my $platform = $platform_dependent{'arch_str'}->{$arch};
	doSystemCommand("$launchVisualStudioEnv $platform && perl Configure $platform_dependent{'configure_arg'}->{$arch} no-asm shared --prefix=openssl-$platform");
	doSystemCommand("$launchVisualStudioEnv $platform && $platform_dependent{'do_ms'}->{$arch}");
	doSystemCommand("$launchVisualStudioEnv $platform && nmake -f ms\\ntdll.mak install");
	chdir ("..");
}

sub buildOpenSSL
{
	my $dir = shift;
	my $arch = shift;
	
	clean ($dir);
	clone ($dir);
	build ($dir, $arch);
	print("\nDone building OpenSSL\n");
}

1;