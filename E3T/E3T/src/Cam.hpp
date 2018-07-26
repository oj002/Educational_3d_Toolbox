#pragma once

#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <cmath>

#include <vector>

enum class CamMovement
{
	FORWARD,
	BACKWARD,
	LEFT,
	RIGHT
};

static const float YAW = 90.0f;
static const float PITCH = 0.0f;
static const float SPEED = 4.0f;
static const float SENSITIVTY = 0.05f;

class Cam
{
public:
	Cam(glm::vec3 position = glm::vec3(0.0f, 0.0f, 0.0f), glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f), float yaw = YAW, float pitch = PITCH) noexcept
		: front(0.0f, 0.0f, -1.0f)
		, movementSpeed(SPEED)
		, mouseSensitivity(SENSITIVTY)
		, position(position)
		, worldUp(up)
		, yaw(yaw)
		, pitch(pitch)
		, right(0.0f)
		, up(0.0f)
	{
		updateVectors();
	}

	void processKeyboard(CamMovement direction, float deltaTime)
	{
		const float velocity{ this->movementSpeed * deltaTime };
		if (direction == CamMovement::FORWARD) { this->position -= this->front * velocity; }
		if (direction == CamMovement::BACKWARD) { this->position += this->front * velocity; }
		if (direction == CamMovement::LEFT) { this->position += this->right * velocity; }
		if (direction == CamMovement::RIGHT) { this->position -= this->right * velocity; }
	}

	void processMouseMovement(float xOffset, float yOffset, bool constrainPitch = true) noexcept
	{
		xOffset *= this->mouseSensitivity;
		yOffset *= this->mouseSensitivity;
		this->yaw -= xOffset;
		this->pitch -= yOffset;

		if (constrainPitch)
		{
			if (this->pitch > 89.0f) { this->pitch = 89.0f; }
			if (this->pitch < -89.0f) { this->pitch = -89.0f; }
		}

		updateVectors();
	}


private:
	void updateVectors()
	{
		glm::vec3 newFront;
		newFront.x = std::cos(glm::radians(this->yaw)) * cos(glm::radians(this->pitch));
		newFront.y = std::sin(glm::radians(this->pitch));
		newFront.z = std::sin(glm::radians(this->yaw)) * cos(glm::radians(this->pitch));
		this->front = newFront;

		this->right = glm::normalize(glm::cross(this->front, this->worldUp));
		this->up = glm::normalize(glm::cross(this->right, this->front));
	}

public:
	glm::vec3 position;
	glm::vec3 front;
	glm::vec3 up;
	glm::vec3 right;
	glm::vec3 worldUp;

	float yaw;
	float pitch;

	float movementSpeed;
	float mouseSensitivity;
};