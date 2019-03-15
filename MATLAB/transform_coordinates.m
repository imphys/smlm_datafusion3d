function transformed_coordinates = transform_coordinates(coordinates, rotation, shift)
    
shift = repmat(shift, size(coordinates,1),1);
transformed_coordinates =  coordinates * rotation + shift;

end