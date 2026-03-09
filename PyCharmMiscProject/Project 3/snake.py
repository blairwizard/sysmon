import pygame
import time
import collections as c
import random

pygame.init()

WINDOW_SIZE = 600
GRID_COUNT = 20
CELL_SIZE = WINDOW_SIZE // GRID_COUNT

screen = pygame.display.set_mode((WINDOW_SIZE, WINDOW_SIZE))
pygame.display.set_caption("Snake")

clock = pygame.time.Clock()
direction="RIGHT"
snake=c.deque([[10,10]])
food=[random.randint(0,19),random.randint(0,19)]
new_head = [snake[0][0], snake[0][1]]
font = pygame.font.SysFont("Arial", 24)
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_q:
                running = False
            if event.key == pygame.K_UP:
                direction = "UP"
            if event.key == pygame.K_DOWN:
                direction = "DOWN"
            if event.key == pygame.K_RIGHT:
                direction = "RIGHT"
            if event.key == pygame.K_LEFT:
                direction = "LEFT"

        # 1. calculate new head
    new_head = [snake[0][0], snake[0][1]]

    # 2. move based on direction
    if direction == "RIGHT":
        new_head[1] += 1
    elif direction == "LEFT":
        new_head[1] -= 1
    elif direction == "UP":
        new_head[0] -= 1
    elif direction == "DOWN":
        new_head[0] += 1


    # 4. food check - pop only if no food eaten
    if new_head == food:
        food = [random.randint(0, 19), random.randint(0, 19)]
    else:
        snake.pop()
    if new_head in snake:
        print("GAME OVER")
        running=False

    # 5. add new head
    snake.appendleft(new_head)



    # 6. draw everything
    screen.fill((0, 0, 0))
    for segment in snake:
        x = segment[1] * CELL_SIZE
        y = segment[0] * CELL_SIZE
        pygame.draw.rect(screen, "purple", (x, y, CELL_SIZE, CELL_SIZE))

    if new_head[0] < 0 or new_head[0] >= GRID_COUNT or new_head[1] < 0 or new_head[1] >= GRID_COUNT:
        print("GAME OVER")
        running = False


    x1 = food[1] * CELL_SIZE
    y1 = food[0] * CELL_SIZE
    pygame.draw.rect(screen, "red", (x1, y1, CELL_SIZE, CELL_SIZE))
    score_text = font.render(f"Score: {len(snake) - 1}", True, "white")
    screen.blit(score_text, (10, 10))


    pygame.display.flip()
    clock.tick(10)
# game over screen loop
game_over = True
while game_over:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            game_over = False
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_q:
                game_over = False

    screen.fill((0, 0, 0))

    # draw game over text
    big_font = pygame.font.SysFont("Arial", 72)
    game_over_text = big_font.render("GAME OVER", True, "red")
    score_final_text = font.render(f"Final Score: {len(snake) - 1}", True, "white")
    quit_text = font.render("Press Q to quit", True, "white")

    screen.blit(game_over_text, (120, 220))
    screen.blit(score_final_text, (210, 320))
    screen.blit(quit_text, (195, 350))

    pygame.display.flip()
    clock.tick(10)
pygame.quit()