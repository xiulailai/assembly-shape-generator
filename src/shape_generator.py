def read_input(prompt, min_val, max_val):
    try:
        value = int(input(prompt))
        if min_val <= value <= max_val:
            return value
        else:
            print("ERROR: Value out of range!")
            return None
    except ValueError:
        print("ERROR: Invalid input format!")
        return None


def draw_rectangle(width, height):
    for row in range(height):
        for col in range(width):
            print('*', end='')
        print()

def handle_rectangle():
    width = read_input("Enter width (1-80): ", 1, 80)
    if width is None:
        return

    height = read_input("Enter height (1-30): ", 1, 30)
    if height is None:
        return

    print()
    draw_rectangle(width, height)


def draw_square(size):
    draw_rectangle(size, size)


def handle_square():
    size = read_input("Enter size (1-30): ", 1, 30)
    if size is None:
        return

    print()
    draw_square(size)


def draw_triangle(size):
    for row in range(size):
        # Number of stars = row number + 1
        for col in range(row + 1):
            print('*', end='')
        print()

def handle_triangle():
    size = read_input("Enter size (1-30): ", 1, 30)
    if size is None:
        return

    print()
    draw_triangle(size)


def draw_circle(radius):
    # Calculate grid dimensions
    diameter = 2 * radius + 1

    for row in range(diameter):
        for col in range(diameter):
            # Calculate relative position from center
            dx = col - radius
            dy = row - radius

            # Calculate distance squared
            dist_squared = dx * dx + dy * dy

            # Calculate radius squared
            radius_squared = radius * radius

            # Calculate inner radius squared (radius - 1)²
            inner_radius = max(0, radius - 1)
            inner_radius_squared = inner_radius * inner_radius

            # Check if point is on the circle edge
            # inner_radius² <= dist² <= radius²
            if inner_radius_squared <= dist_squared <= radius_squared:
                print('*', end='')
            else:
                print(' ', end='')
        print()

def handle_circle():
    radius = read_input("Enter radius (1-15): ", 1, 15)
    if radius is None:
        return

    print()
    draw_circle(radius)


def main():
    while True:
        print("SHAPE GENERATION SYSTEM")
        print("1. Draw Rectangle")
        print("2. Draw Square")
        print("3. Draw Triangle (Right-angled)")
        print("4. Draw Circle (Approximation)")
        print("5. Exit")
        choice = read_input("\nEnter choice (1-5): ", 1, 5)

        if choice is None:
            continue

        if choice == 1:
            handle_rectangle()
        elif choice == 2:
            handle_square()
        elif choice == 3:
            handle_triangle()
        elif choice == 4:
            handle_circle()
        elif choice == 5:
            print("\nThank you for using Shape Generator!")
            break
        else:
            print("\nERROR: Invalid choice! Please enter 1-5.")

main()