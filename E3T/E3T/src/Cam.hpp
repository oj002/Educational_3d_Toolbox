#pragma once

#include <glad/glad.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

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
static const float SPEED = 3.5f;
static const float SENSITIVTY = 0.05f;

class Cam
{
public:
	Cam(glm::vec3 position = glm::vec3(0.0f, 0.0f, 0.0f), glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f), float yaw = YAW, float pitch = PITCH)
		: front(glm::vec3(0.0f, 0.0f, -1.0f))
		, movementSpeed(SPEED)
		, mouseSensitivity(SENSITIVTY)
	{
		this->position = position;
		this->worldUp = up;
		this->yaw = yaw;
		this->pitch = pitch;
		updateVectors();
	}

	Cam(float posX, float posY, float posZ, float upX, float upY, float upZ, float yaw, float pitch)
		: front(glm::vec3(0.0f, 0.0f, -1.0f))
		, movementSpeed(SPEED)
		, mouseSensitivity(SENSITIVTY)
	{
		this->position = glm::vec3(posX, posY, posZ);
		this->worldUp = glm::vec3(upX, upY, upZ);
		this->yaw = yaw;
		this->pitch = pitch;
		updateVectors();
	}

	void processKeyboard(CamMovement direction, float deltaTime)
	{
		float velocity = this->movementSpeed * deltaTime;
		if (direction == CamMovement::FORWARD) { this->position -= this->front * velocity; }
		if (direction == CamMovement::BACKWARD) { this->position += this->front * velocity; }
		if (direction == CamMovement::LEFT) { this->position += this->right * velocity; }
		if (direction == CamMovement::RIGHT) { this->position -= this->right * velocity; }
	}

	void processMouseMovement(float xOffset, float yOffset, bool constrainPitch = true)
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
		newFront.x = cos(glm::radians(this->yaw)) * cos(glm::radians(this->pitch));
		newFront.y = sin(glm::radians(this->pitch));
		newFront.z = sin(glm::radians(this->yaw)) * cos(glm::radians(this->pitch));
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