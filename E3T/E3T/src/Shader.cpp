#include "Shader.hpp"
#include <regex>
#include <experimental\filesystem>

namespace fs = std::experimental::filesystem;

namespace E3T
{
	Shader::Shader()
		: m_rendererID(0)
	{
		m_vs = CompileShader(GL_VERTEX_SHADER,"#version 400 core\nlayout(location=0)in vec2 aPos;out vec2 fragPos;void main(){fragPos=aPos;gl_Position=vec4(aPos,0.0,1.0);}");
		
		CreateShader("#version 400 core\nin vec2 fragPos;out vec4 fragColor;void main(){fragColor=vec4(0.0,0.0,0.0,1.0);}");
	}

	void Shader::update(const char *filepath)
	{

		static long long lastTimeModified{ 0 };
		const long long time{ fs::last_write_time(fs::current_path().append(filepath)).time_since_epoch().count() };
		if (lastTimeModified < time)
		{
			lastTimeModified = time;
			GLCall(glDeleteProgram(m_rendererID));
			m_uniformLocationCache.clear();

			CreateShader(PaseShader(filepath));
			this->bind();
		}
	}

	std::string Shader::PaseLib(const char *libPath)
	{
		const long long lastWriteTime{ fs::last_write_time(fs::current_path().append(libPath)).time_since_epoch().count() };

		if (auto libEntry{ m_libs.find(libPath) }; libEntry != m_libs.end())
			if(libEntry->second.lastWriteTime >= lastWriteTime)
				return libEntry->second.forward_declare;

		// m_libs.clear();

		std::ifstream fin(libPath);
		if (!fin.is_open())
		{
			std::cerr << "Warning: shader lib '" << libPath << "' doesn't exist\n";
		}
		std::string lib_str("#version 400 core\n" + std::string((std::istreambuf_iterator<char>(fin)), std::istreambuf_iterator<char>()));

		static std::regex remove_single_line_comments("//.*\n", std::regex::optimize);
		lib_str = std::regex_replace(lib_str, remove_single_line_comments, "");

		Library lib;
		lib.lastWriteTime = lastWriteTime;
		lib.id = CompileShader(GL_FRAGMENT_SHADER, lib_str);

		for (std::string::const_iterator it{ lib_str.begin() }; it != lib_str.end(); ++it)
		{
			switch (*it)
			{
			case '\n': case '\r': case '\v': break;
			case '#': while(*++it != '\n') {} break;
			case ')':
				lib.forward_declare += ')';
				do {
					if (*++it == '{') {
						int brackets{ 1 };
						while (brackets != 0) {
							switch (*++it)
							{
							case '{': ++brackets; break;
							case '}':
								--brackets;
								if (brackets == 0) lib.forward_declare += ';';
								else if (brackets < 0) std::cerr << "Unopened braked closed!" << std::endl;
								break;
							}
						}
						++it; break;// So the -- at the end gets negated
					}
				} while (isspace(*it) || *it == '\n');
				--it; break;
			default:
				lib.forward_declare += *it; break;
			}
		}

		fin.close();
		m_libs[libPath] = lib;
		return lib.forward_declare;
	}

	std::string Shader::PaseShader(const char *filePath)
	{
		std::ifstream fin(filePath);
		if (!fin.is_open())
		{
			std::cerr << "Warning: shader '" << filePath << "' doesn't exist\n";
		}
		std::string shader("#version 400 core\n");
		std::string line;
		while (std::getline(fin, line))
		{
			size_t index{ line.find("#import") };
			if (index != std::string::npos)
			{
				const size_t open{ line.find('"', index) + 1 };
				std::string libName{ line.substr(open, line.find('"', open) - open) };

				shader += PaseLib(libName.c_str()) + '\n';
			}
			else
			{
				shader += line + '\n';
			}
		}
		return shader;
	}

	unsigned int Shader::CompileShader(unsigned int type, const std::string & sourc)
	{
		GLCall(const unsigned int id = glCreateShader(type));
		const char* src = sourc.c_str();
		GLCall(glShaderSource(id, 1, &src, nullptr));
		GLCall(glCompileShader(id));

		int result;
		GLCall(glGetShaderiv(id, GL_COMPILE_STATUS, &result));
		if (result == GL_FALSE)
		{
			int lenght;
			GLCall(glGetShaderiv(id, GL_INFO_LOG_LENGTH, &lenght));
			char* message = (char*)alloca(lenght * sizeof(char));
			GLCall(glGetShaderInfoLog(id, lenght, &lenght, message));
			std::cerr << "Failed to compile Shader: " << message << std::endl;
			GLCall(glDeleteShader(id));
			return 0;
		}

		return id;
	}

	void Shader::CreateShader(const std::string &fragmentShader)
	{
		const unsigned int fs{ CompileShader(GL_FRAGMENT_SHADER, fragmentShader) };
		GLCall(m_rendererID = glCreateProgram());

		GLCall(glAttachShader(m_rendererID, m_vs));
		for (const auto &it : m_libs)
		{
			GLCall(glAttachShader(m_rendererID, it.second.id));
		}
		GLCall(glAttachShader(m_rendererID, fs));
		GLCall(glLinkProgram(m_rendererID));
		GLCall(glValidateProgram(m_rendererID));

		GLCall(glDeleteShader(fs));
	}


	int Shader::getUniformLocation(const std::string & name)
	{
		if (m_uniformLocationCache.find(name) != m_uniformLocationCache.end())
		{
			return m_uniformLocationCache[name];
		}
		GLCall(int location = glGetUniformLocation(m_rendererID, name.c_str()));

		m_uniformLocationCache[name] = location;
		return location;
	}
}
