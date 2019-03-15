function pointset_out = random_rotate_z(pointset_in, step_size)

symmetry_order = 2 * pi / step_size;

angle = step_size * floor(symmetry_order * rand);
r = rotz(rad2deg(angle));
pointset_out = pointset_in * r';

end