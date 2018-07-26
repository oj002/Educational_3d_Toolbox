#pragma once

#include <string>

#include <fstream>
#include <sstream>

#include "Macros.hpp"
#include <glad\glad.h>

#include <unordered_map>
#include <glm\glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <fstream>
#include <regex>

#include <experimental\filesystem>
namespace fs = std::experimental::filesystem;

namespace E3T
{
	class Shader
	{
	public:
		Shader(const char *libPath);
		~Shader() { GLCall(glDeleteProgram(m_rendererID)); }


		void bind() const noexcept { GLCall(glUseProgram(m_rendererID)); }
		void unbind() const noexcept { GLCall(glUseProgram(0)); }

		void setFloat(const std::string& name, float v) { GLCall(glUniform1f(getUniformLocation(name), v)); }
		void setInt(const std::string& name, int v) { GLCall(glUniform1i(getUniformLocation(name), v)); }

		void setVec2(const std::string& name, const glm::vec2& vec) { GLCall(glUniform2f(getUniformLocation(name), vec.x, vec.y)); }
		void setVec3(const std::string& name, const glm::vec3& vec) { GLCall(glUniform3f(getUniformLocation(name), vec.x, vec.y, vec.z)); }
		void setVec4(const std::string& name, const glm::vec4& vec) { GLCall(glUniform4f(getUniformLocation(name), vec.x, vec.y, vec.z, vec.w)); }
		void setMat4(const std::string& name, const glm::mat4& mat) { GLCall(glUniformMatrix4fv(getUniformLocation(name), 1, GL_FALSE, glm::value_ptr(mat))); }

		void update(const char *filepath);
	private:
		std::string PaseShader(const char *filePath);
		unsigned int CompileShader(unsigned int type, const std::string& sourc);
		void CreateShader(const std::string& fragmentShader);
		int getUniformLocation(const std::string& name);

	private:
		std::string forward_declare;
		unsigned int m_rendererID;
		unsigned int m_vs, m_libFs;
		std::unordered_map<std::string, int> m_uniformLocationCache;
	};
}