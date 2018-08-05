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
		for (auto it : u_bool)  { setBool(it.first, it.second);  }
		for (auto it : u_bvec2) { setBVec2(it.first, it.second); }
		for (auto it : u_bvec3) { setBVec3(it.first, it.second); }
		for (auto it : u_bvec4) { setBVec4(it.first, it.second); }

		for (auto it : u_int)   { setInt(it.first, it.second);   }
		for (auto it : u_ivec2) { setIVec2(it.first, it.second); }
		for (auto it : u_ivec3) { setIVec3(it.first, it.second); }
		for (auto it : u_ivec4) { setIVec4(it.first, it.second); }

		for (auto it : u_uint)  { setUInt(it.first, it.second);  }
		for (auto it : u_uivec2){ setUVec2(it.first, it.second); }
		for (auto it : u_uivec3){ setUVec3(it.first, it.second); }
		for (auto it : u_uivec4){ setUVec4(it.first, it.second); }

		for (auto it : u_float) { setFloat(it.first, it.second); }
		for (auto it : u_vec2)  { setVec2(it.first, it.second);  }
		for (auto it : u_vec3)  { setVec3(it.first, it.second);  }
		for (auto it : u_vec4)  { setVec4(it.first, it.second);  }

		for (auto it : u_double){ setDouble(it.first, it.second);}
		for (auto it : u_dvec2) { setDVec2(it.first, it.second); }
		for (auto it : u_dvec3) { setDVec3(it.first, it.second); }
		for (auto it : u_dvec4) { setDVec4(it.first, it.second); }
	}

	void Shader::render_uniforms()
	{
		if (ImGui::CollapsingHeader("uniforms"))
		{
			for (auto it : m_imguiCalls)
			{
				if (it.first == "uniforms")
				{
					for (auto func : it.second)
					{
						func();
					}
				}
				else if (ImGui::TreeNode(it.first.c_str()))
				{
					for (auto func : it.second)
					{
						func();
					}
					ImGui::TreePop();
				}
			}
		}
	}

	std::string Shader::PaseLib(const std::string &libPath)
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
		u_bool.clear(); u_bvec2.clear(); u_bvec3.clear(); u_bvec4.clear();
		u_int.clear(); u_ivec2.clear(); u_ivec3.clear(); u_ivec4.clear();
		u_uint.clear(); u_uivec2.clear(); u_uivec3.clear(); u_uivec4.clear();
		u_float.clear(); u_vec2.clear(); u_vec3.clear(); u_vec4.clear();
		u_double.clear(); u_dvec2.clear(); u_dvec3.clear(); u_dvec4.clear();
		m_imguiCalls.clear();

		std::ifstream fin(filePath);
		if (!fin.is_open())
		{
			std::cerr << "Warning: shader '" << filePath << "' doesn't exist\n";
		}

		std::string shader_str(std::string((std::istreambuf_iterator<char>(fin)), std::istreambuf_iterator<char>()));
		static const std::regex remove_single_line_comments("//.*\n", std::regex::optimize);
		shader_str = std::regex_replace(shader_str, remove_single_line_comments, "");

		std::string shader("#version 400 core\n");

		for (std::string::const_iterator it{ shader_str.begin() }; it != shader_str.end(); ++it)
		{
			switch (*it)
			{
			case '@':
			{
				const size_t start{ static_cast<size_t>(it - shader_str.begin()) };
				const size_t end{ static_cast<size_t>(shader_str.find_first_of('\n', start)) };
				std::stringstream ss(shader_str.substr(start + 1, end));
				it += end - start;
				std::string identifier;
				ss >> identifier;

				if (identifier == "import")
				{
					std::string path;
					ss >> path;
					shader += PaseLib(path.substr(1, path.size() - 2)) + '\n';
				}
				else if (identifier == "ImGui_uniform")
				{
					std::string type, name;
					ss >> type;
					ss >> name;
					std::getline(ss, identifier);
					std::string funcName;
					size_t i{ 0 };
					while (isspace(identifier[i])) { ++i; }
					while (isalnum(identifier[i])) { funcName += identifier[i]; ++i; }
					while (isspace(identifier[i])) { ++i; }
					++i; // remove '('
					ss.str(identifier.substr(i));
					#include "imgui_func_parser.cpp"
				}
			}
			break;
			case '/':
			default:
				shader += *it; break;
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
