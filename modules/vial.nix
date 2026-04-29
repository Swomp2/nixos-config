{config, pkgs, ...}:
{
	services.udev.packages = with pkgs; [
	    vial
	    via
	];

	environment.systemPackages = with pkgs; [
		vial
	];
}
