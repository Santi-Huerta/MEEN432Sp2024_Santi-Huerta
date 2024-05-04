test_position = [];
test_speed = [];

for x = -200:1100
    if x >= 90 && x <= 810
        test_speed = [test_speed, 600];
    else
        test_speed = [test_speed,20];
    end
    test_position = [test_position, x];
end

% Parameters
radius = 200;           % Radius of curved sections
straight_length = 900;  % Length of straightaways
track_width = 7.5;       % Width of the track
car_width = 20;    % Width of the rectangle
car_height = 10;   % Height of the rectangle

x1 = [];
y1 = [];
x1c = [];
y1c = [];
x2 = [];
y2 = [];
x2c = [];
y2c = [];


% generate straights for track 
for i = 0:straight_length/8
    x1 = [x1,8*i];
    y1 = [y1,0];

    x2 = [x2, straight_length - 8*i];
    y2 = [y2, 2*radius];
end

% generate curves for track
for i = 0:180
    x1c = [x1c,radius*cosd(i-90) + straight_length];
    y1c = [y1c,radius*sind(i-90) + radius];

    x2c = [x2c,radius*cosd(i+90)];
    y2c = [y2c,radius*sind(i+90) + radius];
end

% Combine all coordinates to form the complete race track
x_track = [x1, x1c, x2, x2c];
y_track = [y1, y1c, y2, y2c];

x_min = -400;
x_max = 1300;

y_min = -400;
y_max = 800;


% Plot the race track
figure;

% Plot solid background color
patch([x_min, x_max, x_max, x_min], [y_min, y_min, y_max, y_max], [1 .5 .5], 'EdgeColor', 'none');

hold on
plot(x_track, y_track, 'LineWidth', track_width,'Color','k');
hold off
axis equal;
xlabel('X-axis (m)');
ylabel('Y-axis (m)');
title('Race Track');
grid on;

%create patch for car
car_vertices = [-car_width/2, -car_height/2; car_width/2, -car_height/2; car_width/2, car_height/2; -car_width/2, car_height/2];
car = patch('Vertices', car_vertices, 'Faces', [1 2 3 4], 'EdgeColor', 'k', 'FaceColor', 'g');

% start animation of line 
animate1 = animatedline('Color','r','LineWidth',1.1);
animate2 = animatedline('Color','r','LineWidth',1.1);

%start simulation
simout = sim("Project4Sim.slx", "StopTime","3600");

time = simout.tout;
X = simout.X_driven.Data;
Y = simout.Y_driven.Data;
Psi = simout.Psi_driven.Data;


% Animated line for the car's trajectory
h = animatedline('Color', 'magenta', 'LineWidth', 2);

% starts iterating at each track point
for i = 1:length(X)

    vehicle_x = X(i); % x position of patch
    vehicle_y = Y(i); % y position of patch
    vehicle_angle = -Psi(i);

    addpoints(h, vehicle_x, vehicle_y)

    rotation_matrix = [cos(vehicle_angle), -sin(vehicle_angle); sin(vehicle_angle), cos(vehicle_angle)];
    rotated_vertices = car_vertices * rotation_matrix;

    % Update the position and rotation of the car
    set(car, 'Vertices', rotated_vertices + [vehicle_x, vehicle_y]);


    if ishandle(car)
        set(car, 'Vertices', rotated_vertices + [vehicle_x, vehicle_y]);
    else
        disp('Car object handle is invalid or deleted.');
    end


    drawnow
end


path.width = track_width;
path.l_st = straight_length;
path.radius = radius;

race = raceStat(X, Y, time, path, simout);
disp(race)





